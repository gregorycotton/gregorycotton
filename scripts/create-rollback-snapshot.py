#!/usr/bin/env python3
"""Create a self-contained dynamic-site rollback kit."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sqlite3
import stat
import subprocess
import tarfile
import tempfile
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
DEFAULT_LEGACY_COMMIT = "781a12d4b81a4ef92c06520ae322f33a54e4258e"
FTS_PREFIXES = ("projects_fts", "fieldnotes_fts")
LEGACY_REQUIRED_FILES = [
    "index.html",
    "server.php",
    "style.css",
    "footer.html",
    "scripts/app.js",
    "scripts/config.js",
    "scripts/fetch-properties.js",
    "scripts/image-loader.js",
    "scripts/table-manager.js",
    "scripts/admin/new-uuid.php",
    "scripts/admin/rate-limit.js",
    "scripts/admin/update-album-img-size.php",
    "scripts/admin/update-uuids.php",
]


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def git_value(*arguments: str) -> str:
    return subprocess.run(
        ["git", *arguments],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()


def repository_label(path: Path) -> str:
    try:
        return path.relative_to(ROOT).as_posix()
    except ValueError:
        return path.as_posix()


def portable_sql_dump(source: sqlite3.Connection) -> str:
    # FTS5 tables are rebuildable indexes. Their generated shadow-table SQL is
    # not portable, so the PHP runtime recreates them after a SQL restoration.
    lines = [
        line
        for line in source.iterdump()
        if not any(token in line for token in FTS_PREFIXES)
    ]
    return "\n".join(lines) + "\n"


def portable_table_counts(source: sqlite3.Connection) -> dict[str, int]:
    names = [
        row[0]
        for row in source.execute(
            "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name"
        )
        if not row[0].startswith("sqlite_")
        and not row[0].startswith(FTS_PREFIXES)
    ]
    return {
        name: source.execute(
            f'SELECT COUNT(*) FROM "{name.replace(chr(34), chr(34) * 2)}"'
        ).fetchone()[0]
        for name in names
    }


def legacy_commit_details(reference: str) -> dict[str, str]:
    commit = git_value("rev-parse", f"{reference}^{{commit}}")
    details = git_value(
        "show",
        "-s",
        "--date=iso-strict",
        "--format=%H%x00%ad%x00%s",
        commit,
    ).split("\x00")
    if len(details) != 3:
        raise ValueError(f"could not read legacy commit metadata for {reference}")
    return {"commit": details[0], "date": details[1], "subject": details[2]}


def create_legacy_archive(path: Path, commit: str) -> None:
    subprocess.run(
        [
            "git",
            "archive",
            "--format=tar.gz",
            f"--output={path}",
            commit,
        ],
        cwd=ROOT,
        check=True,
    )
    with tarfile.open(path, "r:gz") as archive:
        members = {member.name.rstrip("/") for member in archive.getmembers()}
    missing = sorted(set(LEGACY_REQUIRED_FILES) - members)
    if missing:
        raise ValueError(
            "legacy archive is incomplete; missing: " + ", ".join(missing)
        )


def rollback_guide(package_name: str, legacy: dict[str, str]) -> str:
    commit = legacy["commit"]
    return f"""# Dynamic-site rollback kit

Package: `{package_name}`
Legacy code: `{commit}` ({legacy['date']}, {legacy['subject']})

This package restores `gregorycotton.ca` to the PHP/SQLite runtime that existed
immediately before the static-site migration. It does not contain, configure,
or modify `fridge.gregorycotton.ca`.

## Contents

- `legacy-site.tar.gz`: exact Git archive of the pre-static site.
- `projects.db`: exact SQLite backup, including the rebuildable FTS indexes.
- `projects.sql`: portable SQL export without FTS5 virtual/shadow tables.
- `legacy-helpers/update-db.sh`: private legacy database uploader, when present.
- `manifest.json`: Git metadata, table counts, and SHA-256 checksums.

## Verify locally

From the repository root:

```bash
python3 scripts/test-rollback-snapshot.py database/rollback/{package_name}
```

Do not continue to the server procedure unless verification passes.

## Emergency server rollback

The following is a manual emergency procedure. It deliberately creates a new
release and changes only the `gregorycotton.ca/current` symlink and that site's
database. It does not change Nginx configuration or the Fridge service.

1. Upload this package's `projects.db` to a temporary path:

```bash
scp database/rollback/{package_name}/projects.db greg@65.108.243.52:/home/greg/projects.db.rollback-upload
```

2. SSH to the server and record the currently active static release:

```bash
ssh greg@65.108.243.52
readlink -f /var/www/gregorycotton.ca/current
```

Keep that path: it is the immediate roll-forward target if verification fails.

3. Create a server-side backup and install the rollback database atomically:

```bash
mkdir -p /home/greg/backups/gregorycotton.ca
SERVER_BACKUP="/home/greg/backups/gregorycotton.ca/projects.db.before-dynamic-$(date +%Y%m%d%H%M%S)"
sqlite3 /var/www/gregorycotton.ca/database/projects.db ".backup '$SERVER_BACKUP'"
sqlite3 /home/greg/projects.db.rollback-upload 'PRAGMA integrity_check;'
sudo systemctl stop php8.2-fpm
sudo install -o www-data -g www-data -m 664 /home/greg/projects.db.rollback-upload /var/www/gregorycotton.ca/database/projects.db
sudo systemctl start php8.2-fpm
```

4. Create a legacy release directly from the existing bare Git repository:

```bash
LEGACY_COMMIT="{commit}"
ROLLBACK_RELEASE="/var/www/gregorycotton.ca/releases/rollback-$(date +%Y%m%d%H%M%S)"
mkdir -p "$ROLLBACK_RELEASE"
git --work-tree="$ROLLBACK_RELEASE" --git-dir=/home/greg/git-repos/gregorycotton.ca.git checkout -f "$LEGACY_COMMIT"
find "$ROLLBACK_RELEASE" -type d -exec chmod 755 {{}} \\;
find "$ROLLBACK_RELEASE" -type f -exec chmod 644 {{}} \\;
```

5. Check PHP and Nginx before switching traffic:

```bash
test -f "$ROLLBACK_RELEASE/server.php"
test -f "$ROLLBACK_RELEASE/scripts/fetch-properties.js"
sudo systemctl is-active php8.2-fpm
sudo nginx -t
```

6. Activate the release and smoke-test both sites:

```bash
ln -sfn "$ROLLBACK_RELEASE" /var/www/gregorycotton.ca/current
curl -fsS 'https://gregorycotton.ca/server.php?action=get_projects' >/dev/null
curl -fsSI 'https://gregorycotton.ca/' | head
curl -fsSI 'https://fridge.gregorycotton.ca/' | head
```

If the main-site checks fail, point `/var/www/gregorycotton.ca/current` back to
the static release path recorded in step 2. The database backup path printed in
step 3 can be restored with SQLite's `.restore` command.

## Encrypted off-device copy

Create a passphrase file outside the repository with permissions `600`, then
generate a new kit with `--encrypted-copy` and `--passphrase-file`. The command
creates an AES-256 encrypted archive and a separate SHA-256 sidecar. Store both
off the computer. The passphrase must be stored separately from the archive.
"""


def collect_file_manifest(target: Path) -> dict[str, dict[str, object]]:
    files: dict[str, dict[str, object]] = {}
    for path in sorted(item for item in target.rglob("*") if item.is_file()):
        relative = path.relative_to(target).as_posix()
        files[relative] = {"sha256": sha256_file(path), "sizeBytes": path.stat().st_size}
    return files


def validate_private_passphrase_file(path: Path) -> None:
    if not path.is_file():
        raise ValueError(f"passphrase file does not exist: {path}")
    try:
        path.relative_to(ROOT)
    except ValueError:
        pass
    else:
        raise ValueError("passphrase file must be stored outside the repository")
    if stat.S_IMODE(path.stat().st_mode) & 0o077:
        raise ValueError("passphrase file permissions must be 600")
    if not path.read_text(encoding="utf-8").strip():
        raise ValueError("passphrase file is empty")


def encrypted_copy(package: Path, output: Path, passphrase_file: Path) -> Path:
    validate_private_passphrase_file(passphrase_file)
    try:
        output.relative_to(ROOT)
    except ValueError:
        pass
    else:
        raise ValueError("encrypted backup must be written outside the repository")
    sidecar = output.with_name(output.name + ".sha256")
    if output.exists() or sidecar.exists():
        raise FileExistsError(f"encrypted backup already exists: {output}")
    output.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="rollback-encrypt-") as temporary_name:
        archive_path = Path(temporary_name) / f"{package.name}.tar.gz"
        with tarfile.open(archive_path, "w:gz") as archive:
            archive.add(package, arcname=package.name)
        try:
            subprocess.run(
                [
                    "openssl",
                    "enc",
                    "-aes-256-cbc",
                    "-salt",
                    "-pbkdf2",
                    "-iter",
                    "200000",
                    "-md",
                    "sha256",
                    "-in",
                    str(archive_path),
                    "-out",
                    str(output),
                    "-pass",
                    f"file:{passphrase_file}",
                ],
                check=True,
            )
        except Exception:
            output.unlink(missing_ok=True)
            raise
    sidecar.write_text(f"{sha256_file(output)}  {output.name}\n", encoding="utf-8")
    return sidecar


def snapshot(
    database_path: Path,
    output_dir: Path,
    name: str | None,
    legacy_reference: str,
) -> Path:
    if not database_path.is_file():
        raise FileNotFoundError(f"SQLite database not found: {database_path}")
    legacy = legacy_commit_details(legacy_reference)

    with sqlite3.connect(database_path) as source:
        integrity = source.execute("PRAGMA integrity_check").fetchone()[0]
        if integrity != "ok":
            raise ValueError(f"SQLite integrity check failed: {integrity}")
        counts = portable_table_counts(source)
        sql_dump = portable_sql_dump(source)

    current_commit = git_value("rev-parse", "HEAD")
    if name is None:
        timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        name = f"{timestamp}-{current_commit[:7]}"
    if not name or Path(name).name != name or name in {".", ".."}:
        raise ValueError("rollback-kit name must be a single directory name")
    output_dir.mkdir(parents=True, exist_ok=True)
    target = output_dir / name
    building = output_dir / f".{name}.building"
    if target.exists() or building.exists():
        raise FileExistsError(f"rollback kit already exists: {target}")
    building.mkdir()

    try:
        binary_path = building / "projects.db"
        with sqlite3.connect(database_path) as source, sqlite3.connect(binary_path) as destination:
            source.backup(destination)
        (building / "projects.sql").write_text(sql_dump, encoding="utf-8")
        create_legacy_archive(building / "legacy-site.tar.gz", legacy["commit"])

        private_helper = ROOT / "scripts/admin/update-db.sh"
        if private_helper.is_file():
            helper_destination = building / "legacy-helpers/update-db.sh"
            helper_destination.parent.mkdir()
            shutil.copy2(private_helper, helper_destination)

        (building / "ROLLBACK.md").write_text(
            rollback_guide(name, legacy), encoding="utf-8"
        )
        manifest = {
            "formatVersion": 2,
            "kitType": "dynamic-php-rollback",
            "createdAt": datetime.now(timezone.utc).isoformat(),
            "sourceDatabase": repository_label(database_path),
            "gitCommit": current_commit,
            "workingTreeStatus": git_value("status", "--short"),
            "legacyRuntime": {
                **legacy,
                "archive": "legacy-site.tar.gz",
                "requiredFiles": LEGACY_REQUIRED_FILES,
            },
            "integrity": integrity,
            "counts": counts,
            "sqlExcludedTablePrefixes": list(FTS_PREFIXES),
            "deployment": {
                "site": "gregorycotton.ca",
                "gitDirectory": "/home/greg/git-repos/gregorycotton.ca.git",
                "database": "/var/www/gregorycotton.ca/database/projects.db",
                "releases": "/var/www/gregorycotton.ca/releases",
                "liveSymlink": "/var/www/gregorycotton.ca/current",
                "untouchedService": "fridge.gregorycotton.ca",
            },
            "files": collect_file_manifest(building),
        }
        (building / "manifest.json").write_text(
            json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
        )
        building.rename(target)
    except Exception:
        shutil.rmtree(building, ignore_errors=True)
        raise
    return target


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, default=ROOT / "database/projects.db")
    parser.add_argument("--output-dir", type=Path, default=ROOT / "database/rollback")
    parser.add_argument("--name", help="explicit rollback-kit directory name")
    parser.add_argument(
        "--legacy-commit",
        default=DEFAULT_LEGACY_COMMIT,
        help="pre-static Git commit to archive",
    )
    parser.add_argument(
        "--encrypted-copy",
        type=Path,
        help="optional encrypted archive destination outside the repository",
    )
    parser.add_argument(
        "--passphrase-file",
        type=Path,
        help="600-permission passphrase file outside the repository",
    )
    args = parser.parse_args()
    if bool(args.encrypted_copy) != bool(args.passphrase_file):
        parser.error("--encrypted-copy and --passphrase-file must be used together")

    try:
        target = snapshot(
            args.database.resolve(),
            args.output_dir.resolve(),
            args.name,
            args.legacy_commit,
        )
        print(f"Rollback kit created: {target}")
        if args.encrypted_copy:
            sidecar = encrypted_copy(
                target,
                args.encrypted_copy.resolve(),
                args.passphrase_file.resolve(),
            )
            print(f"Encrypted copy created: {args.encrypted_copy.resolve()}")
            print(f"Encrypted checksum created: {sidecar}")
    except (OSError, ValueError, sqlite3.Error, subprocess.CalledProcessError) as error:
        parser.exit(1, f"rollback kit creation failed: {error}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
