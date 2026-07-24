#!/usr/bin/env python3
"""Create a version-labelled SQLite and SQL rollback package."""

from __future__ import annotations

import argparse
import hashlib
import json
import sqlite3
import subprocess
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def git_value(*arguments: str) -> str:
    try:
        return subprocess.run(
            ["git", *arguments], cwd=ROOT, check=True, capture_output=True, text=True
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return "unknown"


def portable_sql_dump(source: sqlite3.Connection) -> str:
    # FTS5 virtual tables are rebuildable indexes; omit their generated internals
    # because sqlite3.iterdump() emits non-portable sqlite_master inserts for them.
    excluded_tokens = ("projects_fts", "fieldnotes_fts")
    lines = [
        line
        for line in source.iterdump()
        if not any(token in line for token in excluded_tokens)
    ]
    return "\n".join(lines) + "\n"


def snapshot(database_path: Path, output_dir: Path, name: str | None) -> Path:
    with sqlite3.connect(database_path) as source:
        integrity = source.execute("PRAGMA integrity_check").fetchone()[0]
        if integrity != "ok":
            raise ValueError(f"SQLite integrity check failed: {integrity}")
        counts = {
            table: source.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
            for table in ("projects", "fieldnotes")
        }
        sql_dump = portable_sql_dump(source)

    commit = git_value("rev-parse", "--short", "HEAD")
    if name is None:
        timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        name = f"{timestamp}-{commit}"
    target = output_dir / name
    if target.exists():
        raise FileExistsError(f"rollback snapshot already exists: {target}")
    target.mkdir(parents=True)

    binary_path = target / "projects.db"
    with sqlite3.connect(database_path) as source, sqlite3.connect(binary_path) as destination:
        source.backup(destination)
    sql_path = target / "projects.sql"
    sql_path.write_text(sql_dump, encoding="utf-8")

    manifest = {
        "formatVersion": 1,
        "createdAt": datetime.now(timezone.utc).isoformat(),
        "sourceDatabase": str(database_path.relative_to(ROOT)),
        "gitCommit": git_value("rev-parse", "HEAD"),
        "workingTreeStatus": git_value("status", "--short"),
        "integrity": integrity,
        "counts": counts,
        "sqlExcludedTables": ["projects_fts", "fieldnotes_fts"],
        "files": {
            "projects.db": {"sha256": sha256_file(binary_path)},
            "projects.sql": {"sha256": sha256_file(sql_path)},
        },
    }
    (target / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return target


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, default=ROOT / "database/projects.db")
    parser.add_argument("--output-dir", type=Path, default=ROOT / "database/rollback")
    parser.add_argument("--name", help="explicit snapshot directory name")
    args = parser.parse_args()
    target = snapshot(args.database.resolve(), args.output_dir.resolve(), args.name)
    print(f"Rollback snapshot created: {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
