#!/usr/bin/env python3
"""Export the SQLite catalogue into deterministic static build artifacts."""

from __future__ import annotations

import argparse
import hashlib
import html
import json
import re
import sqlite3
import sys
from pathlib import Path


BUILDER_VERSION = 1
CATALOGUE_SCHEMA_VERSION = 1

ONTOLOGY_COLUMNS = [
    "UUID",
    "Title",
    "ShortDescription",
    "Year",
    "Modality",
    "Medium",
    "Tools",
    "Object",
    "Collaborators",
    "Keywords",
    "FeaturedWork",
]
FIELDNOTE_COLUMNS = [
    "UUID",
    "Title",
    "ShortDescription",
    "PublishedDate",
    "LastUpdated",
    "ReadingTimeMinutes",
    "WordCount",
]

DEFAULT_COLUMNS = {
    "ontology": ["Title", "ShortDescription", "Year", "Object"],
    "fieldnotes": [
        "Title",
        "ShortDescription",
        "PublishedDate",
        "LastUpdated",
        "ReadingTimeMinutes",
    ],
}

METADATA_TABLES = {
    "Modality": ("modalities", "Modality"),
    "Medium": ("mediums", "Medium"),
    "Tools": ("tools", "Tool"),
    "Object": ("objects", "Object"),
    "Collaborators": ("collaborators", "Collaborator"),
    "Keywords": ("keywords", "Keyword"),
}


class BuildError(Exception):
    """A user-correctable catalogue build failure."""


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def quote_identifier(identifier: str) -> str:
    return '"' + identifier.replace('"', '""') + '"'


def require_columns(connection: sqlite3.Connection, table: str, columns: list[str]) -> None:
    table_name = quote_identifier(table)
    actual = {
        row[1]
        for row in connection.execute(f"PRAGMA table_info({table_name})")
    }
    missing = [column for column in columns if column not in actual]
    if missing:
        raise BuildError(
            f"{table} is missing required columns: {', '.join(missing)}"
        )


def load_metadata(
    connection: sqlite3.Connection, table: str, column: str
) -> dict[str, list[str]]:
    table_name = quote_identifier(table)
    column_name = quote_identifier(column)
    values: dict[str, list[str]] = {}
    query = (
        f"SELECT UUID, {column_name} FROM {table_name} "
        f"ORDER BY UUID, {column_name} COLLATE NOCASE"
    )
    for row in connection.execute(query):
        uuid = row[0]
        value = row[1]
        if not uuid or value is None or value == "":
            continue
        values.setdefault(uuid, [])
        if value not in values[uuid]:
            values[uuid].append(value)
    return values


def validate_record(record: dict, view: str, root: Path) -> None:
    for field in ("UUID", "Title", "URL"):
        if not record.get(field):
            raise BuildError(f"{view} record is missing {field}: {record!r}")

    uuid = record["UUID"]
    url = record["URL"]
    if any(separator in url for separator in ("/", "\\")) or url in {".", ".."}:
        raise BuildError(f"Unsafe {view} URL slug for {uuid}: {url!r}")

    page_path = root / view / f"{url}.html"
    if not page_path.is_file():
        raise BuildError(f"Missing page for {view} URL {url!r}: {page_path}")


def load_records(connection: sqlite3.Connection, root: Path) -> dict[str, list[dict]]:
    require_columns(connection, "projects", ONTOLOGY_COLUMNS[:4] + ["FeaturedWork", "URL"])
    require_columns(connection, "fieldnotes", FIELDNOTE_COLUMNS + ["URL"])
    for table, column in METADATA_TABLES.values():
        require_columns(connection, table, ["UUID", column])

    metadata = {
        field: load_metadata(connection, table, column)
        for field, (table, column) in METADATA_TABLES.items()
    }

    project_rows = []
    project_query = """
        SELECT UUID, Title, ShortDescription, Year, FeaturedWork, URL
        FROM projects
        ORDER BY Year DESC, Title COLLATE NOCASE, UUID
    """
    for row in connection.execute(project_query):
        record = dict(row)
        for field in METADATA_TABLES:
            record[field] = metadata[field].get(record["UUID"], [])
        validate_record(record, "ontology", root)
        project_rows.append(record)

    fieldnote_rows = []
    fieldnote_query = """
        SELECT UUID, Title, ShortDescription, PublishedDate, LastUpdated,
               ReadingTimeMinutes, WordCount, URL
        FROM fieldnotes
        ORDER BY PublishedDate DESC, Title COLLATE NOCASE, UUID
    """
    for row in connection.execute(fieldnote_query):
        record = dict(row)
        validate_record(record, "fieldnotes", root)
        fieldnote_rows.append(record)

    project_ids = {record["UUID"] for record in project_rows}
    for field, values in metadata.items():
        orphaned = sorted(set(values) - project_ids)
        if orphaned:
            raise BuildError(
                f"{field} contains metadata for unknown project UUIDs: "
                f"{', '.join(orphaned)}"
            )

    for view, records in (("ontology", project_rows), ("fieldnotes", fieldnote_rows)):
        urls = [record["URL"] for record in records]
        if len(urls) != len(set(urls)):
            raise BuildError(f"Duplicate URL slug found in {view}")

    return {"ontology": project_rows, "fieldnotes": fieldnote_rows}


def display_name(column: str) -> str:
    labels = {
        "FeaturedWork": "Featured",
        "PublishedDate": "Published",
        "LastUpdated": "Updated",
        "ReadingTimeMinutes": "Reading Time",
        "WordCount": "Word Count",
    }
    if column in labels:
        return labels[column]
    if column == "UUID":
        return column
    return re.sub(r"([A-Z])", r" \1", column).strip()


def cell_value(value: object) -> str:
    if value is None or value == "":
        return "N/A"
    if isinstance(value, list):
        return ", ".join(str(item) for item in value) or "N/A"
    return str(value)


def render_table(view: str, records: list[dict]) -> str:
    columns = DEFAULT_COLUMNS[view]
    table_id = "projectsTable" if view == "ontology" else "fieldnotesTable"
    page_directory = "ontology" if view == "ontology" else "fieldnotes"

    header = "".join(
        f"        <th>{html.escape(display_name(column))}</th>\n"
        for column in columns
    )
    rows = []
    for record in records:
        cells = []
        for column in columns:
            value = cell_value(record.get(column))
            if column == "Title":
                href = f"/{page_directory}/{record['URL']}.html"
                value = (
                    f'<a class="table-link" href="{html.escape(href, quote=True)}">'
                    f"{html.escape(value)}</a>"
                )
            else:
                value = html.escape(value)
            cells.append(f"            <td>{value}</td>")
        rows.append("        <tr>\n" + "\n".join(cells) + "\n        </tr>")

    return (
        f'<table id="{table_id}" data-generated-catalogue="true">\n'
        "    <thead>\n"
        "      <tr>\n"
        f"{header}"
        "      </tr>\n"
        "    </thead>\n"
        "    <tbody>\n"
        + ("\n".join(rows) + "\n" if rows else "")
        + "    </tbody>\n"
        "</table>\n"
    )


def write_json(path: Path, value: object) -> None:
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2, sort_keys=False) + "\n",
        encoding="utf-8",
    )


def build(database_path: Path, output_dir: Path, root: Path) -> dict:
    if not database_path.is_file():
        raise BuildError(f"Database not found: {database_path}")

    connection = sqlite3.connect(database_path)
    connection.row_factory = sqlite3.Row
    try:
        integrity = connection.execute("PRAGMA integrity_check").fetchone()[0]
        if integrity != "ok":
            raise BuildError(f"SQLite integrity check failed: {integrity}")
        records = load_records(connection, root)
    finally:
        connection.close()

    source_hash = sha256_file(database_path)
    catalogue = {
        "schemaVersion": CATALOGUE_SCHEMA_VERSION,
        "source": {
            "database": database_path.relative_to(root).as_posix(),
            "sha256": source_hash,
        },
        "views": {
            "ontology": {
                "columns": ONTOLOGY_COLUMNS,
                "defaultColumns": DEFAULT_COLUMNS["ontology"],
                "rows": records["ontology"],
            },
            "fieldnotes": {
                "columns": FIELDNOTE_COLUMNS,
                "defaultColumns": DEFAULT_COLUMNS["fieldnotes"],
                "rows": records["fieldnotes"],
            },
        },
    }

    output_dir.mkdir(parents=True, exist_ok=True)
    write_json(output_dir / "catalogue.json", catalogue)
    (output_dir / "ontology.html").write_text(
        render_table("ontology", records["ontology"]), encoding="utf-8"
    )
    (output_dir / "fieldnotes.html").write_text(
        render_table("fieldnotes", records["fieldnotes"]), encoding="utf-8"
    )

    manifest = {
        "builder": {
            "path": "scripts/build-catalogue.py",
            "version": BUILDER_VERSION,
        },
        "catalogueSchemaVersion": CATALOGUE_SCHEMA_VERSION,
        "source": {
            "database": database_path.relative_to(root).as_posix(),
            "sha256": source_hash,
        },
        "counts": {
            "ontology": len(records["ontology"]),
            "fieldnotes": len(records["fieldnotes"]),
        },
        "outputs": ["catalogue.json", "ontology.html", "fieldnotes.html"],
    }
    write_json(output_dir / "manifest.json", manifest)
    return manifest


def parse_args() -> argparse.Namespace:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--database",
        type=Path,
        default=root / "database/projects.db",
        help="SQLite database path (default: database/projects.db)",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=root / ".build/catalogue",
        help="Output directory (default: .build/catalogue)",
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=root,
        help=argparse.SUPPRESS,
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = args.root.resolve()
    database_path = args.database.resolve()
    output_dir = args.output_dir.resolve()
    try:
        manifest = build(database_path, output_dir, root)
    except (BuildError, OSError, sqlite3.Error) as error:
        print(f"Catalogue build failed: {error}", file=sys.stderr)
        return 1

    print(
        "Catalogue build complete: "
        f"{manifest['counts']['ontology']} ontology records, "
        f"{manifest['counts']['fieldnotes']} fieldnotes -> {output_dir}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
