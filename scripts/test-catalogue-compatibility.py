#!/usr/bin/env python3
"""Compare static catalogue behavior with the existing local PHP runtime."""

from __future__ import annotations

import json
import re
import atexit
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib.parse import quote, unquote


ROOT = Path(__file__).resolve().parents[1]
CATALOGUE_PATH = ROOT / ".build/catalogue/catalogue.json"
METADATA_FIELDS = {"Modality", "Medium", "Tools", "Object", "Collaborators", "Keywords"}
ONTOLOGY_FIELDS = [
    "UUID", "Title", "ShortDescription", "Year", "Modality", "Medium", "Tools",
    "Object", "Collaborators", "Keywords", "FeaturedWork", "URL",
]
FIELDNOTE_FIELDS = [
    "UUID", "Title", "ShortDescription", "PublishedDate", "LastUpdated",
    "ReadingTimeMinutes", "WordCount", "URL",
]
SEARCH_FIELDS = {
    "ontology": [
        "UUID", "Title", "ShortDescription", "Year", "Modality", "Medium",
        "Tools", "Object", "Collaborators", "Keywords",
    ],
    "fieldnotes": [
        "UUID", "Title", "ShortDescription", "PublishedDate", "LastUpdated",
        "WordCount", "ReadingTimeMinutes",
    ],
}
URL_OPERATOR_BY_QUERY_OPERATOR = {
    "IS": "=", "IS NOT": "!=", "CONTAINS": "~", "STARTS WITH": "*=",
    "ENDS WITH": "$=", "GREATER THAN": ">", "LESS THAN": "<",
    "PUBLISHED ON": "=", "UPDATED ON": "=", "PUBLISHED BEFORE": "<=",
    "UPDATED BEFORE": "<=", "PUBLISHED AFTER": ">=", "UPDATED AFTER": ">=",
}
URL_OPERATOR_TOKENS = [">=", "<=", "!=", "*=", "$=", "=", "~", ">", "<"]
RUNTIME_ROOT: Path | None = None


def runtime_root() -> Path:
    global RUNTIME_ROOT
    if RUNTIME_ROOT is None:
        temporary = Path(tempfile.mkdtemp(prefix="catalogue-runtime-"))
        (temporary / "database").mkdir()
        shutil.copy2(ROOT / "server.php", temporary / "server.php")
        shutil.copy2(ROOT / "database/projects.db", temporary / "database/projects.db")
        atexit.register(shutil.rmtree, temporary, ignore_errors=True)
        RUNTIME_ROOT = temporary
    return RUNTIME_ROOT


def php_string(value: object) -> str:
    return "'" + str(value).replace("\\", "\\\\").replace("'", "\\'") + "'"


def run_php_api(action: str, *, term: str | None = None, conditions: list[dict] | None = None) -> list[dict]:
    assignments = [f"$_GET['action'] = {php_string(action)};"]
    if term is not None:
        assignments.append(f"$_GET['term'] = {php_string(term)};")
    if conditions is not None:
        encoded = ", ".join(
            "array(" + ", ".join(
                f"'{key}' => {php_string(condition[key])}"
                for key in ("logic", "field", "operator", "value")
            ) + ")"
            for condition in conditions
        )
        assignments.append(f"$_GET['conditions'] = array({encoded});")

    result = subprocess.run(
        ["php", "-r", " ".join(assignments) + " include 'server.php';"],
        cwd=runtime_root(),
        check=True,
        capture_output=True,
        text=True,
    )
    output = result.stdout.strip()
    json_start = next((index for index, char in enumerate(output) if char in "[{"), -1)
    if json_start < 0:
        raise AssertionError(f"PHP API returned no JSON for {action}: {output}")
    return json.loads(output[json_start:])


def normalize_record(record: dict, fields: list[str]) -> dict:
    normalized = {}
    for field in fields:
        value = record.get(field)
        if field in METADATA_FIELDS:
            if isinstance(value, list):
                value = [str(item).strip() for item in value if str(item).strip()]
            elif value:
                value = [item.strip() for item in str(value).split(",") if item.strip()]
            else:
                value = []
            value.sort(key=str.casefold)
        normalized[field] = value
    return normalized


def assert_record_parity(name: str, runtime: list[dict], static: list[dict], fields: list[str]) -> None:
    runtime_by_uuid = {row["UUID"]: normalize_record(row, fields) for row in runtime}
    static_by_uuid = {row["UUID"]: normalize_record(row, fields) for row in static}
    assert sorted(runtime_by_uuid) == sorted(static_by_uuid), f"{name}: UUID sets differ"
    for uuid in runtime_by_uuid:
        assert static_by_uuid[uuid] == runtime_by_uuid[uuid], f"{name}: record differs for {uuid}"


def record_values(record: dict, field: str) -> list[object]:
    value = record.get(field)
    return value if isinstance(value, list) else [value]


def condition_matches(record: dict, condition: dict, view: str) -> bool:
    field = condition["field"]
    operator = condition["operator"]
    expected = str(condition.get("value", "")).strip()
    raw_value = record.get(field)
    values = [str(value) for value in record_values(record, field) if value not in (None, "")]
    normalized = [value.casefold() for value in values]

    if view == "ontology" and field == "FeaturedWork" and expected.upper() == "FALSE":
        is_false = raw_value in (None, "") or str(raw_value).upper() == "FALSE"
        return is_false if operator in {"IS", "IS NOT"} else False
    if operator == "IS":
        return expected in values
    if operator == "IS NOT":
        return all(value != expected for value in values) if field in METADATA_FIELDS else raw_value is not None and expected not in values
    if operator == "CONTAINS":
        return expected.casefold() in " ".join(normalized)
    if operator == "STARTS WITH":
        return any(value.startswith(expected.casefold()) for value in normalized)
    if operator == "ENDS WITH":
        return any(value.endswith(expected.casefold()) for value in normalized)
    if operator in {"GREATER THAN", "LESS THAN"}:
        try:
            actual_number = float(raw_value)
            expected_number = float(expected)
        except (TypeError, ValueError):
            return False
        return actual_number > expected_number if operator == "GREATER THAN" else actual_number < expected_number
    if operator in {"PUBLISHED ON", "UPDATED ON"}:
        return expected in values
    if operator in {"PUBLISHED BEFORE", "UPDATED BEFORE"}:
        return any(value <= expected for value in values)
    if operator in {"PUBLISHED AFTER", "UPDATED AFTER"}:
        return any(value >= expected for value in values)
    return False


def filter_conditions(rows: list[dict], conditions: list[dict], view: str) -> list[dict]:
    filtered = []
    for row in rows:
        if not conditions:
            filtered.append(row)
            continue
        result = condition_matches(row, conditions[0], view)
        for condition in conditions[1:]:
            match = condition_matches(row, condition, view)
            result = (result or match) if condition["logic"] == "OR" else (result and match)
        if result:
            filtered.append(row)
    return filtered


def search_rows(rows: list[dict], view: str, term: str) -> list[dict]:
    tokens = re.findall(r"[\w-]+", term, flags=re.UNICODE)
    if not tokens:
        return list(rows)
    normalized_tokens = [token.casefold() for token in tokens]
    result = []
    for row in rows:
        searchable = " ".join(
            str(value)
            for field in SEARCH_FIELDS[view]
            for value in record_values(row, field)
            if value is not None
        ).casefold()
        if all(token in searchable for token in normalized_tokens):
            result.append(row)
    return result


def ids(rows: list[dict]) -> list[str]:
    return sorted(row["UUID"] for row in rows)


def serialize_conditions(conditions: list[dict]) -> str:
    segments = []
    for index, condition in enumerate(conditions):
        logic = "OR" if str(condition.get("logic", "AND")).upper() == "OR" else "AND"
        prefix = f"{logic}:" if index > 0 else ""
        field = quote(condition["field"], safe="")
        value = quote(str(condition["value"]).strip(), safe="")
        segments.append(f"{prefix}{field}{URL_OPERATOR_BY_QUERY_OPERATOR[condition['operator']]}{value}")
    return "^".join(segments)


def parse_conditions(encoded: str, view: str) -> list[dict]:
    operator_by_token = {
        "=": "IS", "!=": "IS NOT", "~": "CONTAINS", "*=": "STARTS WITH",
        "$=": "ENDS WITH", ">": "GREATER THAN", "<": "LESS THAN",
    }
    result = []
    for index, segment in enumerate(encoded.split("^")):
        logic = "AND"
        expression = segment.strip()
        if index > 0 and expression.upper().startswith(("OR:", "AND:")):
            logic, expression = expression[:2].upper(), expression[3:]
        matches = [
            (expression.find(token), token)
            for token in URL_OPERATOR_TOKENS
            if expression.find(token) > 0
        ]
        if not matches:
            continue
        operator_index, token = sorted(matches, key=lambda item: (item[0], -len(item[1])))[0]
        field = unquote(expression[:operator_index].strip())
        value = unquote(expression[operator_index + len(token):].strip())
        if view == "fieldnotes" and field == "PublishedDate":
            operator = {"=": "PUBLISHED ON", "<=": "PUBLISHED BEFORE", ">=": "PUBLISHED AFTER"}.get(token)
        elif view == "fieldnotes" and field == "LastUpdated":
            operator = {"=": "UPDATED ON", "<=": "UPDATED BEFORE", ">=": "UPDATED AFTER"}.get(token)
        else:
            operator = operator_by_token.get(token)
        if field and value and operator:
            result.append({"logic": logic, "field": field, "operator": operator, "value": value})
    return result


def main() -> int:
    catalogue = json.loads(CATALOGUE_PATH.read_text(encoding="utf-8"))
    ontology = catalogue["views"]["ontology"]["rows"]
    fieldnotes = catalogue["views"]["fieldnotes"]["rows"]

    assert_record_parity("projects", run_php_api("get_projects"), ontology, ONTOLOGY_FIELDS)
    assert_record_parity("fieldnotes", run_php_api("get_fieldnotes"), fieldnotes, FIELDNOTE_FIELDS)
    print("record parity passed")

    search_cases = [
        ("search_projects", "Kyoto", "ontology", ontology),
        ("search_projects", "digital camera", "ontology", ontology),
        ("search_fieldnotes", "Hello world", "fieldnotes", fieldnotes),
        ("search_fieldnotes", "", "fieldnotes", fieldnotes),
    ]
    for action, term, view, rows in search_cases:
        assert ids(run_php_api(action, term=term)) == ids(search_rows(rows, view, term)), f"{action} search differs for {term}"
    print("search parity passed")

    query_cases = [
        ("query_projects", "ontology", ontology, [{"logic": "AND", "field": "Year", "operator": "GREATER THAN", "value": "2023"}]),
        ("query_projects", "ontology", ontology, [{"logic": "AND", "field": "Medium", "operator": "IS", "value": "Browser"}]),
        ("query_projects", "ontology", ontology, [
            {"logic": "AND", "field": "Year", "operator": "LESS THAN", "value": "2020"},
            {"logic": "OR", "field": "FeaturedWork", "operator": "IS", "value": "TRUE"},
        ]),
        ("query_fieldnotes", "fieldnotes", fieldnotes, [{"logic": "AND", "field": "Title", "operator": "CONTAINS", "value": "world"}]),
        ("query_fieldnotes", "fieldnotes", fieldnotes, [{"logic": "AND", "field": "PublishedDate", "operator": "PUBLISHED AFTER", "value": "2020-01-01"}]),
    ]
    for action, view, rows, conditions in query_cases:
        assert ids(run_php_api(action, conditions=conditions)) == ids(filter_conditions(rows, conditions, view)), f"{action} query differs"
    print("query parity passed")

    assert [row["UUID"] for row in ontology] == [row["UUID"] for row in sorted(ontology, key=lambda row: (-int(row["Year"] or 0), str(row["Title"]).casefold(), row["UUID"]))]
    assert [row["UUID"] for row in fieldnotes] == [row["UUID"] for row in sorted(fieldnotes, key=lambda row: (str(row["PublishedDate"] or ""), str(row["Title"]).casefold(), row["UUID"]), reverse=True)]
    print("sort order parity passed")

    conditions = [
        {"logic": "AND", "field": "Year", "operator": "GREATER THAN", "value": "2023"},
        {"logic": "OR", "field": "FeaturedWork", "operator": "IS", "value": "TRUE"},
    ]
    assert parse_conditions(serialize_conditions(conditions), "ontology") == conditions
    print("query URL round-trip passed")
    print("catalogue compatibility tests passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        print(f"Catalogue compatibility tests failed: {error}", file=sys.stderr)
        raise SystemExit(1)
