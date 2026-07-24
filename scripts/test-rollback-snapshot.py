#!/usr/bin/env python3
"""Verify a rollback package restores SQLite, PHP runtime, and static builds."""

from __future__ import annotations

import argparse
import json
import shutil
import sqlite3
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent


def sha256_file(path: Path) -> str:
    import hashlib

    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def php_runtime_counts(database_path: Path, temporary: Path) -> dict[str, int]:
    runtime = temporary / "php-runtime"
    (runtime / "database").mkdir(parents=True)
    shutil.copy2(ROOT / "server.php", runtime / "server.php")
    shutil.copy2(database_path, runtime / "database/projects.db")
    values: dict[str, int] = {}
    for name, action in (("projects", "get_projects"), ("fieldnotes", "get_fieldnotes")):
        result = subprocess.run(
            ["php", "-r", f"$_GET['action'] = '{action}'; include 'server.php';"],
            cwd=runtime,
            check=True,
            capture_output=True,
            text=True,
        )
        output = result.stdout.strip()
        json_start = next((index for index, char in enumerate(output) if char in "[{"), -1)
        if json_start < 0:
            raise AssertionError(f"PHP runtime returned no JSON for {action}: {output}")
        values[name] = len(json.loads(output[json_start:]))
    return values


def verify(snapshot_dir: Path) -> None:
    manifest_path = snapshot_dir / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    for filename, details in manifest["files"].items():
        path = snapshot_dir / filename
        assert path.is_file(), f"missing rollback file: {filename}"
        assert sha256_file(path) == details["sha256"], f"checksum mismatch: {filename}"

    with tempfile.TemporaryDirectory(prefix="rollback-verify-") as temporary_name:
        temporary = Path(temporary_name)
        restored = temporary / "restored.db"
        shutil.copy2(snapshot_dir / "projects.db", restored)
        with sqlite3.connect(restored) as database:
            assert database.execute("PRAGMA integrity_check").fetchone()[0] == "ok"
            counts = {
                table: database.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
                for table in ("projects", "fieldnotes")
            }
        assert counts == manifest["counts"]

        sql_restored = temporary / "sql-restored.db"
        with sqlite3.connect(sql_restored) as database:
            database.executescript((snapshot_dir / "projects.sql").read_text(encoding="utf-8"))
            assert database.execute("PRAGMA integrity_check").fetchone()[0] == "ok"
            sql_counts = {
                table: database.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
                for table in ("projects", "fieldnotes")
            }
        assert sql_counts == manifest["counts"]

        assert php_runtime_counts(restored, temporary) == manifest["counts"]

        catalogue_output = temporary / "catalogue"
        homepage = temporary / "index.html"
        shutil.copy2(ROOT / "index.html", homepage)
        subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts/build-catalogue.py"),
                "--database",
                str(restored),
                "--output-dir",
                str(catalogue_output),
                "--homepage",
                str(homepage),
            ],
            cwd=ROOT,
            check=True,
        )
        catalogue = json.loads((catalogue_output / "catalogue.json").read_text(encoding="utf-8"))
        assert len(catalogue["views"]["ontology"]["rows"]) == manifest["counts"]["projects"]
        assert len(catalogue["views"]["fieldnotes"]["rows"]) == manifest["counts"]["fieldnotes"]

        pages_output = temporary / "pages"
        subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts/build-pages.py"),
                "--database",
                str(restored),
                "--output-dir",
                str(pages_output),
            ],
            cwd=ROOT,
            check=True,
        )
        assert len(list(pages_output.joinpath("ontology").glob("*.html"))) == manifest["counts"]["projects"]
        assert len(list(pages_output.joinpath("fieldnotes").glob("*.html"))) == manifest["counts"]["fieldnotes"]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("snapshot_dir", type=Path)
    args = parser.parse_args()
    verify(args.snapshot_dir.resolve())
    print(f"rollback snapshot verification passed: {args.snapshot_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
