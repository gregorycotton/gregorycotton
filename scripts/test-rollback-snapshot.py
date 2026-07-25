#!/usr/bin/env python3
"""Verify a rollback kit restores its database, legacy PHP site, and static build."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import sqlite3
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def expected_table_counts(
    database: sqlite3.Connection, expected: dict[str, int]
) -> dict[str, int]:
    return {
        name: database.execute(
            f'SELECT COUNT(*) FROM "{name.replace(chr(34), chr(34) * 2)}"'
        ).fetchone()[0]
        for name in expected
    }


def php_string(value: str) -> str:
    return "'" + value.replace("\\", "\\\\").replace("'", "\\'") + "'"


def php_action(runtime: Path, action: str, **parameters: str) -> object:
    assignments = [f"$_GET['action'] = {php_string(action)};"]
    assignments.extend(
        f"$_GET[{php_string(key)}] = {php_string(value)};"
        for key, value in parameters.items()
    )
    result = subprocess.run(
        ["php", "-r", " ".join(assignments) + " include 'server.php';"],
        cwd=runtime,
        check=True,
        capture_output=True,
        text=True,
    )
    output = result.stdout.strip()
    json_start = next((index for index, char in enumerate(output) if char in "[{"), -1)
    if json_start < 0:
        raise AssertionError(f"PHP runtime returned no JSON for {action}: {output}")
    return json.loads(output[json_start:])


def php_runtime_smoke(
    server_php: Path,
    database_path: Path,
    temporary: Path,
    expected: dict[str, int],
    label: str,
) -> None:
    runtime = temporary / f"php-{label}"
    (runtime / "database").mkdir(parents=True)
    shutil.copy2(server_php, runtime / "server.php")
    shutil.copy2(database_path, runtime / "database/projects.db")

    projects = php_action(runtime, "get_projects")
    fieldnotes = php_action(runtime, "get_fieldnotes")
    assert isinstance(projects, list) and len(projects) == expected["projects"]
    assert isinstance(fieldnotes, list) and len(fieldnotes) == expected["fieldnotes"]
    project_search = php_action(runtime, "search_projects", term="Kyoto")
    fieldnote_search = php_action(runtime, "search_fieldnotes", term="Hello world")
    assert isinstance(project_search, list) and project_search, "legacy project search failed"
    assert isinstance(fieldnote_search, list) and fieldnote_search, "legacy fieldnote search failed"


def safe_extract(archive_path: Path, destination: Path) -> None:
    destination = destination.resolve()
    with tarfile.open(archive_path, "r:*") as archive:
        for member in archive.getmembers():
            if member.issym() or member.islnk():
                raise AssertionError(f"rollback archive contains a link: {member.name}")
            target = (destination / member.name).resolve()
            try:
                target.relative_to(destination)
            except ValueError as error:
                raise AssertionError(
                    f"rollback archive path escapes destination: {member.name}"
                ) from error
        archive.extractall(destination, filter="data")


def verify_legacy_archive(
    snapshot_dir: Path,
    manifest: dict,
    temporary: Path,
) -> Path:
    legacy = manifest["legacyRuntime"]
    archive_path = snapshot_dir / legacy["archive"]
    runtime = temporary / "legacy-site"
    runtime.mkdir()
    safe_extract(archive_path, runtime)
    for relative in legacy["requiredFiles"]:
        assert (runtime / relative).is_file(), f"legacy archive is missing {relative}"
    assert "server.php" in (runtime / "scripts/app.js").read_text(encoding="utf-8")
    assert "fetch-properties.js" in (
        runtime / "ontology/anvil.html"
    ).read_text(encoding="utf-8")
    assert legacy["commit"] in (snapshot_dir / "ROLLBACK.md").read_text(
        encoding="utf-8"
    )
    return runtime


def verify_checksums(snapshot_dir: Path, manifest: dict) -> None:
    for filename, details in manifest["files"].items():
        path = snapshot_dir / filename
        assert path.is_file(), f"missing rollback file: {filename}"
        assert sha256_file(path) == details["sha256"], f"checksum mismatch: {filename}"
        if "sizeBytes" in details:
            assert path.stat().st_size == details["sizeBytes"], f"size mismatch: {filename}"


def restore_binary(snapshot_dir: Path, temporary: Path, expected: dict[str, int]) -> Path:
    restored = temporary / "restored-binary.db"
    shutil.copy2(snapshot_dir / "projects.db", restored)
    with sqlite3.connect(restored) as database:
        assert database.execute("PRAGMA integrity_check").fetchone()[0] == "ok"
        assert expected_table_counts(database, expected) == expected
    return restored


def restore_sql(snapshot_dir: Path, temporary: Path, expected: dict[str, int]) -> Path:
    restored = temporary / "restored-sql.db"
    with sqlite3.connect(restored) as database:
        database.executescript((snapshot_dir / "projects.sql").read_text(encoding="utf-8"))
        assert database.execute("PRAGMA integrity_check").fetchone()[0] == "ok"
        assert expected_table_counts(database, expected) == expected
    return restored


def verify_static_build(database_path: Path, expected: dict[str, int], temporary: Path) -> None:
    catalogue_output = temporary / "catalogue"
    homepage = temporary / "index.html"
    shutil.copy2(ROOT / "index.html", homepage)
    subprocess.run(
        [
            sys.executable,
            str(ROOT / "scripts/build-catalogue.py"),
            "--database",
            str(database_path),
            "--output-dir",
            str(catalogue_output),
            "--homepage",
            str(homepage),
        ],
        cwd=ROOT,
        check=True,
    )
    catalogue = json.loads((catalogue_output / "catalogue.json").read_text(encoding="utf-8"))
    assert len(catalogue["views"]["ontology"]["rows"]) == expected["projects"]
    assert len(catalogue["views"]["fieldnotes"]["rows"]) == expected["fieldnotes"]

    pages_output = temporary / "pages"
    subprocess.run(
        [
            sys.executable,
            str(ROOT / "scripts/build-pages.py"),
            "--database",
            str(database_path),
            "--output-dir",
            str(pages_output),
        ],
        cwd=ROOT,
        check=True,
    )
    assert len(list(pages_output.joinpath("ontology").glob("*.html"))) == expected["projects"]
    assert len(list(pages_output.joinpath("fieldnotes").glob("*.html"))) == expected["fieldnotes"]


def verify(snapshot_dir: Path) -> None:
    manifest_path = snapshot_dir / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    verify_checksums(snapshot_dir, manifest)

    with tempfile.TemporaryDirectory(prefix="rollback-verify-") as temporary_name:
        temporary = Path(temporary_name)
        binary = restore_binary(snapshot_dir, temporary, manifest["counts"])
        sql = restore_sql(snapshot_dir, temporary, manifest["counts"])

        if manifest.get("formatVersion", 1) >= 2:
            legacy_runtime = verify_legacy_archive(snapshot_dir, manifest, temporary)
            server_php = legacy_runtime / "server.php"
        else:
            server_php = ROOT / "server.php"

        php_runtime_smoke(server_php, binary, temporary, manifest["counts"], "binary")
        php_runtime_smoke(server_php, sql, temporary, manifest["counts"], "sql")
        verify_static_build(binary, manifest["counts"], temporary)


def verify_encrypted_checksum(encrypted_path: Path) -> None:
    sidecar = encrypted_path.with_name(encrypted_path.name + ".sha256")
    if not sidecar.is_file():
        raise AssertionError(f"encrypted checksum file is missing: {sidecar}")
    expected = sidecar.read_text(encoding="utf-8").split()[0]
    assert sha256_file(encrypted_path) == expected, "encrypted archive checksum mismatch"


def decrypt_package(encrypted_path: Path, passphrase_file: Path, temporary: Path) -> Path:
    verify_encrypted_checksum(encrypted_path)
    decrypted = temporary / "rollback-kit.tar.gz"
    subprocess.run(
        [
            "openssl",
            "enc",
            "-d",
            "-aes-256-cbc",
            "-pbkdf2",
            "-iter",
            "200000",
            "-md",
            "sha256",
            "-in",
            str(encrypted_path),
            "-out",
            str(decrypted),
            "-pass",
            f"file:{passphrase_file}",
        ],
        check=True,
    )
    extracted = temporary / "decrypted"
    extracted.mkdir()
    safe_extract(decrypted, extracted)
    packages = [path for path in extracted.iterdir() if path.is_dir()]
    if len(packages) != 1:
        raise AssertionError("encrypted archive must contain exactly one rollback-kit directory")
    return packages[0]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("snapshot", type=Path, help="rollback-kit directory or encrypted archive")
    parser.add_argument(
        "--passphrase-file",
        type=Path,
        help="passphrase file required when verifying an encrypted archive",
    )
    args = parser.parse_args()
    snapshot = args.snapshot.resolve()
    try:
        if snapshot.is_dir():
            if args.passphrase_file:
                parser.error("--passphrase-file is only used with an encrypted archive")
            verify(snapshot)
            verified = snapshot
        else:
            if not args.passphrase_file:
                parser.error("--passphrase-file is required for an encrypted archive")
            with tempfile.TemporaryDirectory(prefix="rollback-decrypt-") as temporary_name:
                package = decrypt_package(
                    snapshot,
                    args.passphrase_file.resolve(),
                    Path(temporary_name),
                )
                verify(package)
                verified = snapshot
    except (
        AssertionError,
        OSError,
        ValueError,
        KeyError,
        json.JSONDecodeError,
        sqlite3.Error,
        subprocess.CalledProcessError,
        tarfile.TarError,
    ) as error:
        parser.exit(1, f"rollback-kit verification failed: {error}\n")
    print(f"rollback-kit verification passed: {verified}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
