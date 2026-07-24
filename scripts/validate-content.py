#!/usr/bin/env python3
"""Validate Markdown page sources before the static page generator is added."""

from __future__ import annotations

import argparse
import sqlite3
import sys
import tempfile
import tomllib
from pathlib import Path
from urllib.parse import urlparse


class ValidationError(ValueError):
    pass


RESOURCE_TYPES = {"image", "link", "download", "embed", "iframe"}
TEMPLATES = {"project", "fieldnote", "custom"}


def parse_page(path: Path) -> tuple[dict, str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "+++":
        raise ValidationError("front matter must start with +++")

    try:
        end = next(index for index, line in enumerate(lines[1:], 1) if line.strip() == "+++")
    except StopIteration as error:
        raise ValidationError("front matter has no closing +++") from error

    try:
        metadata = tomllib.loads("\n".join(lines[1:end]))
    except tomllib.TOMLDecodeError as error:
        raise ValidationError(f"invalid TOML front matter: {error}") from error

    if not isinstance(metadata, dict):
        raise ValidationError("front matter must be a TOML table")
    return metadata, "\n".join(lines[end + 1 :]).strip()


def required_string(value: object, field: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ValidationError(f"{field} must be a non-empty string")
    return value.strip()


def validate_url(value: object, field: str) -> str:
    url = required_string(value, field)
    if urlparse(url).scheme not in {"http", "https"}:
        raise ValidationError(f"{field} must use http or https")
    return url


def validate_local_file(value: object, field: str, root: Path) -> str:
    relative = required_string(value, field)
    path = Path(relative)
    if path.is_absolute() or ".." in path.parts:
        raise ValidationError(f"{field} must be a repository-relative path")

    resolved = (root / path).resolve()
    try:
        resolved.relative_to(root)
    except ValueError as error:
        raise ValidationError(f"{field} escapes the repository") from error
    if not resolved.is_file():
        raise ValidationError(f"{field} does not exist: {relative}")
    return relative


def validate_resource(resource: object, index: int, root: Path) -> None:
    if not isinstance(resource, dict):
        raise ValidationError(f"resources[{index}] must be a TOML table")

    resource_type = required_string(resource.get("type"), f"resources[{index}].type")
    if resource_type not in RESOURCE_TYPES:
        allowed = ", ".join(sorted(RESOURCE_TYPES))
        raise ValidationError(f"resources[{index}].type must be one of: {allowed}")

    if "group" in resource:
        required_string(resource["group"], f"resources[{index}].group")

    if resource_type == "image":
        for field in ("title", "alt"):
            required_string(resource.get(field), f"resources[{index}].{field}")
        validate_local_file(resource.get("file"), f"resources[{index}].file", root)
        validate_local_file(resource.get("thumbnail"), f"resources[{index}].thumbnail", root)
    elif resource_type == "download":
        required_string(resource.get("title"), f"resources[{index}].title")
        validate_local_file(resource.get("file"), f"resources[{index}].file", root)
    elif resource_type == "link":
        required_string(resource.get("title"), f"resources[{index}].title")
        validate_url(resource.get("url"), f"resources[{index}].url")
    elif resource_type == "embed":
        required_string(resource.get("title"), f"resources[{index}].title")
        required_string(resource.get("provider"), f"resources[{index}].provider")
        validate_url(resource.get("url"), f"resources[{index}].url")
    elif resource_type == "iframe":
        required_string(resource.get("title"), f"resources[{index}].title")
        validate_url(resource.get("url"), f"resources[{index}].url")


def validate_page(path: Path, root: Path, database: sqlite3.Connection) -> None:
    metadata, body = parse_page(path)
    kind = required_string(metadata.get("kind"), "kind")
    if kind not in {"project", "fieldnote"}:
        raise ValidationError("kind must be project or fieldnote")

    slug = required_string(metadata.get("slug"), "slug")
    if path.stem != slug:
        raise ValidationError(f"filename must match slug: expected {slug}.md")
    if "/" in slug or "\\" in slug or slug in {".", ".."}:
        raise ValidationError("slug must be a single safe path component")

    template = metadata.get("template", kind)
    if template not in TEMPLATES:
        raise ValidationError("template must be project, fieldnote, or custom")
    if "display_title" in metadata:
        required_string(metadata["display_title"], "display_title")
    resources = metadata.get("resources", [])
    if not isinstance(resources, list):
        raise ValidationError("resources must be an array of TOML tables")
    if not body and not resources:
        raise ValidationError("Markdown body must not be empty")

    table = "projects" if kind == "project" else "fieldnotes"
    match = database.execute(f"SELECT 1 FROM {table} WHERE URL = ?", (slug,)).fetchone()
    if match is None:
        raise ValidationError(f"{kind} slug is not present in SQLite: {slug}")

    for index, resource in enumerate(resources):
        validate_resource(resource, index, root)


def validate_content(content_dir: Path, root: Path, database_path: Path) -> int:
    pages = sorted(content_dir.rglob("*.md"))
    if not pages:
        raise ValidationError(f"no Markdown pages found in {content_dir}")

    with sqlite3.connect(database_path) as database:
        for page in pages:
            try:
                validate_page(page, root, database)
            except ValidationError as error:
                raise ValidationError(f"{page}: {error}") from error
    return len(pages)


def self_test(root: Path, database_path: Path) -> None:
    with tempfile.TemporaryDirectory(prefix="content-schema-") as temporary:
        content = Path(temporary)
        (content / "anvil.md").write_text(
            """+++\nkind = \"project\"\nslug = \"anvil\"\ntemplate = \"project\"\n\n[[resources]]\ntype = \"image\"\ntitle = \"Anvil homepage\"\nfile = \"ontology/images/anvil/anvil-homepage.jpg\"\nthumbnail = \"ontology/thumbnails/anvil/anvil-homepage-thumbnail.jpg\"\nalt = \"Anvil homepage\"\n\n[[resources]]\ntype = \"link\"\ntitle = \"Visit Anvil\"\nurl = \"https://anvil.cool/\"\n\n[[resources]]\ntype = \"download\"\ntitle = \"Download the homepage image\"\nfile = \"ontology/images/anvil/anvil-homepage.jpg\"\n\n[[resources]]\ntype = \"embed\"\nprovider = \"youtube\"\ntitle = \"Anvil video\"\nurl = \"https://www.youtube.com/embed/example\"\n\n[[resources]]\ntype = \"iframe\"\ntitle = \"Anvil companion\"\nurl = \"https://example.com/companion\"\n+++\n# Anvil\n\nPage prose.\n""",
            encoding="utf-8",
        )
        (content / "ajuda.md").write_text(
            """+++\nkind = \"fieldnote\"\nslug = \"ajuda\"\ntemplate = \"fieldnote\"\n+++\n# Ajuda\n\nFieldnote prose.\n""",
            encoding="utf-8",
        )
        assert validate_content(content, root, database_path) == 2

        (content / "unknown.md").write_text(
            "+++\nkind = \"project\"\nslug = \"unknown\"\n+++\n# Unknown\n",
            encoding="utf-8",
        )
        try:
            validate_content(content, root, database_path)
        except ValidationError:
            pass
        else:
            raise AssertionError("unknown SQLite slug should fail validation")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--content-dir", type=Path, help="directory containing Markdown sources")
    parser.add_argument("--database", type=Path, help="SQLite catalogue path")
    parser.add_argument("--self-test", action="store_true", help="run schema checks using temporary fixtures")
    args = parser.parse_args()

    root = Path(__file__).resolve().parent.parent
    database_path = (args.database or root / "database/projects.db").resolve()
    try:
        if args.self_test:
            self_test(root, database_path)
            print("content schema self-tests passed")
        else:
            if args.content_dir is None:
                parser.error("--content-dir is required unless --self-test is used")
            count = validate_content(args.content_dir.resolve(), root, database_path)
            print(f"validated {count} Markdown pages")
    except (OSError, sqlite3.Error, ValidationError, AssertionError) as error:
        print(f"content validation failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
