#!/usr/bin/env python3
"""Build pilot project and fieldnote pages from TOML-front-matter Markdown."""

from __future__ import annotations

import argparse
import html
import importlib.util
import json
import posixpath
import re
import sqlite3
from collections import OrderedDict
from pathlib import Path
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parent.parent
ARRAY_FIELDS = {
    "Modality": ("modalities", "Modality"),
    "Medium": ("mediums", "Medium"),
    "Tools": ("tools", "Tool"),
    "Object": ("objects", "Object"),
    "Collaborators": ("collaborators", "Collaborator"),
    "Keywords": ("keywords", "Keyword"),
}
MARKDOWN_LINK = re.compile(r"!?(\[[^\]]*\])\(([^)\s]+)(?:\s+['\"]([^'\"]*)['\"])?\)")
HTML_TAG = re.compile(r"(<[^>]+>)")


def load_validator():
    path = ROOT / "scripts/validate-content.py"
    spec = importlib.util.spec_from_file_location("content_validator", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"could not load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def load_record(database: sqlite3.Connection, kind: str, slug: str) -> dict:
    table = "projects" if kind == "project" else "fieldnotes"
    row = database.execute(f"SELECT * FROM {table} WHERE URL = ?", (slug,)).fetchone()
    if row is None:
        raise ValueError(f"SQLite row not found for {kind}:{slug}")
    record = dict(row)
    if kind == "project":
        for field, (metadata_table, metadata_column) in ARRAY_FIELDS.items():
            values = database.execute(
                f"SELECT DISTINCT {metadata_column} FROM {metadata_table} WHERE UUID = ? AND {metadata_column} IS NOT NULL AND {metadata_column} != '' ORDER BY {metadata_column} COLLATE NOCASE",
                (record["UUID"],),
            ).fetchall()
            record[field] = [value[0] for value in values]
    return record


def safe_url(value: str, field: str) -> str:
    parsed = urlparse(value)
    if parsed.scheme not in {"http", "https"}:
        raise ValueError(f"{field} must use http or https")
    return value


def public_asset_url(repo_path: str, public_page: str) -> str:
    return posixpath.relpath(repo_path, posixpath.dirname(public_page)).replace("\\", "/")


def inline_markdown(text: str) -> str:
    pieces: list[str] = []
    cursor = 0
    for match in MARKDOWN_LINK.finditer(text):
        pieces.append(inline_text(text[cursor : match.start()]))
        token = match.group(1)
        target = match.group(2)
        label = token[1:-1]
        title = match.group(3)
        if token.startswith("!"):
            pieces.append(
                f'<img src="{html.escape(target, quote=True)}" alt="{html.escape(label, quote=True)}">'
            )
        else:
            attributes = " class=\"primary-link\""
            if urlparse(target).scheme in {"http", "https"}:
                attributes += ' target="_blank" rel="noopener"'
            if title:
                attributes += f' title="{html.escape(title, quote=True)}"'
            pieces.append(
                f'<a href="{html.escape(target, quote=True)}"{attributes}>{inline_text(label)}</a>'
            )
        cursor = match.end()
    pieces.append(inline_text(text[cursor:]))
    return "".join(pieces)


def inline_text(text: str) -> str:
    output: list[str] = []
    for part in HTML_TAG.split(text):
        if not part:
            continue
        if HTML_TAG.fullmatch(part):
            output.append(part)
        else:
            escaped = html.escape(part)
            escaped = re.sub(r"`([^`]+)`", r"<code>\1</code>", escaped)
            escaped = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", escaped)
            escaped = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"<em>\1</em>", escaped)
            output.append(escaped)
    return "".join(output)


def render_markdown(body: str) -> str:
    output: list[str] = []
    paragraph: list[str] = []
    index = 0

    def flush_paragraph() -> None:
        if paragraph:
            output.append(f'<p>{inline_markdown(" ".join(line.strip() for line in paragraph))}</p>')
            paragraph.clear()

    lines = body.splitlines()
    while index < len(lines):
        line = lines[index]
        stripped = line.strip()
        if not stripped:
            flush_paragraph()
            index += 1
            continue
        resource_token = re.fullmatch(r"\{\{resource-block:([^}]+)\}\}", stripped)
        if resource_token:
            flush_paragraph()
            output.append(stripped)
            index += 1
            continue
        if stripped.startswith("```"):
            flush_paragraph()
            language = html.escape(stripped[3:].strip(), quote=True)
            index += 1
            code_lines: list[str] = []
            while index < len(lines) and not lines[index].strip().startswith("```"):
                code_lines.append(lines[index])
                index += 1
            if index < len(lines):
                index += 1
            class_attribute = f' class="language-{language}"' if language else ""
            output.append(f"<pre><code{class_attribute}>{html.escape(chr(10).join(code_lines))}</code></pre>")
            continue
        heading = re.match(r"^(#{1,6})\s+(.+?)\s*#*$", stripped)
        if heading:
            flush_paragraph()
            level = len(heading.group(1))
            output.append(f"<h{level}>{inline_markdown(heading.group(2))}</h{level}>")
            index += 1
            continue
        if stripped.startswith("> ") or stripped == ">":
            flush_paragraph()
            quote_lines: list[str] = []
            while index < len(lines) and (lines[index].strip().startswith("> ") or lines[index].strip() == ">"):
                quote_lines.append(lines[index].strip()[1:].strip())
                index += 1
            output.append(f"<blockquote>{inline_markdown(' '.join(quote_lines))}</blockquote>")
            continue
        if re.match(r"^[-*+]\s+", stripped):
            flush_paragraph()
            items: list[str] = []
            while index < len(lines):
                item = re.match(r"^[-*+]\s+(.+)$", lines[index].strip())
                if item is None:
                    break
                items.append(f"<li>{inline_markdown(item.group(1))}</li>")
                index += 1
            output.append('<ul class="project-list">' + "".join(items) + "</ul>")
            continue
        if stripped.startswith("<") and (stripped.endswith(">") or stripped.startswith("</")):
            flush_paragraph()
            output.append(line)
            index += 1
            continue
        paragraph.append(line)
        index += 1
    flush_paragraph()
    return "\n\n".join(output)


def render_metadata(record: dict) -> str:
    serialized = json.dumps(record, ensure_ascii=False, indent=2)
    return (
        '<details id="propertiesDetails">'
        '<summary class="secondary-link">Metadata</summary>'
        '<div id="properties-content">'
        '<pre class="secondary-text"><code style="font-size: 12px;">'
        f"{html.escape(serialized)}"
        "</code></pre>"
        "</div></details>"
    )


def render_image_group(resources: list[dict], page_rel: str, slug: str, group_index: int) -> tuple[str, list[dict]]:
    rows: list[str] = []
    configurations: list[dict] = []
    for image_index, resource in enumerate(resources):
        file_url = public_asset_url(resource["file"], page_rel)
        thumbnail_url = public_asset_url(resource["thumbnail"], page_rel)
        cell_id = f"fileSize-{slug}-{group_index}-{image_index}"
        rows.append(
            "<tr>"
            f'<td class="thumbnail-col"><img src="{html.escape(thumbnail_url, quote=True)}" alt="{html.escape(resource["alt"], quote=True)}" class="thumbnail-img"></td>'
            f'<td>{inline_markdown(resource["title"])}</td>'
            f'<td id="{cell_id}">{resource["size"]:,}</td>'
            f'<td class="loadImageTrigger" data-fullimageurl="{html.escape(file_url, quote=True)}" data-title="{html.escape(resource["title"], quote=True)}"><a class="table-link">Load {"GIF" if file_url.lower().endswith(".gif") else "image"}</a></td>'
            "</tr>"
        )
        configurations.append({"idForFileSizeCell": cell_id, "fullImageUrl": file_url})
    table_id = f"resourceTable-{slug}-{group_index}"
    table = (
        '<div class="proj-resource-container">'
        '<div class="table-container">'
        f'<table class="image-loader-table" id="{table_id}">'
        '<thead><tr><th class="thumbnail-col">*</th><th>Title</th><th>Size (bytes)</th><th>View</th></tr></thead>'
        f'<tbody>{"".join(rows)}</tbody>'
        "</table></div><div class=\"image-display-area\"></div></div>"
    )
    return table, configurations


def render_resources(resources: list[dict], page_rel: str, slug: str, root: Path) -> tuple[str, list[dict], OrderedDict[str, str]]:
    groups: OrderedDict[str, list[dict]] = OrderedDict()
    for index, resource in enumerate(resources):
        resource = dict(resource)
        if resource["type"] in {"image", "download"}:
            resource["size"] = (root / resource["file"]).stat().st_size
        if resource.get("group"):
            group = resource["group"]
        elif resource["type"] == "image":
            group = "__default_images__"
        else:
            group = f"resource-{index}"
        groups.setdefault(group, []).append(resource)

    output: list[str] = []
    blocks: OrderedDict[str, str] = OrderedDict()
    configurations: list[dict] = []
    for group_index, (group, grouped) in enumerate(groups.items()):
        group_start = len(output)
        if group not in {"__default_images__"} and not group.startswith(("resource-", "block-")):
            output.append(f'<h3 class="resource-group-title">{html.escape(group)}</h3>')
        images = [resource for resource in grouped if resource["type"] == "image"]
        if images:
            block, image_configurations = render_image_group(images, page_rel, slug, group_index)
            output.append(block)
            configurations.extend(image_configurations)
        for resource in grouped:
            resource_type = resource["type"]
            if resource_type == "link":
                url = safe_url(resource["url"], "resource url")
                output.append(
                    '<div class="proj-resource-container">'
                    f'<p><a class="primary-link" target="_blank" rel="noopener" href="{html.escape(url, quote=True)}">{inline_markdown(resource["title"])}</a></p>'
                    "</div>"
                )
            elif resource_type == "download":
                url = public_asset_url(resource["file"], page_rel)
                output.append(
                    '<div class="proj-resource-container">'
                    f'<p><a class="primary-link" href="{html.escape(url, quote=True)}" download>{inline_markdown(resource["title"])}</a> ({resource["size"]:,} bytes)</p>'
                    "</div>"
                )
            elif resource_type in {"embed", "iframe"}:
                url = safe_url(resource["url"], "resource url")
                attributes = [f'src="{html.escape(url, quote=True)}"', f'title="{html.escape(resource["title"], quote=True)}"', 'frameborder="0"']
                if resource_type == "embed":
                    attributes.extend([
                        'allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"',
                        'referrerpolicy="strict-origin-when-cross-origin"',
                        "allowfullscreen",
                    ])
                for name in ("width", "height", "style"):
                    if name in resource:
                        attributes.append(f'{name}="{html.escape(str(resource[name]), quote=True)}"')
                output.append(
                    '<div class="proj-resource-container"><div class="responsive-iframe-container">'
                    f'<iframe {" ".join(attributes)}></iframe>'
                    "</div></div>"
                )
        blocks[group] = "\n\n".join(output[group_start:])
    return "\n\n".join(output), configurations, blocks


def render_page(source: Path, output_dir: Path, root: Path, database: sqlite3.Connection, validator) -> Path:
    metadata, body = validator.parse_page(source)
    kind = metadata["kind"]
    slug = metadata["slug"]
    record = load_record(database, kind, slug)
    page_rel = f"{('ontology' if kind == 'project' else 'fieldnotes')}/{slug}.html"
    output_path = output_dir / page_rel
    output_path.parent.mkdir(parents=True, exist_ok=True)
    description = record.get("ShortDescription") or ""
    title = metadata.get("display_title") or record["Title"]
    home_url = "../"
    scripts = ""
    resources_html, configurations, resource_blocks = render_resources(metadata.get("resources", []), page_rel, slug, root)
    body_html = body if metadata.get("template") == "custom" else render_markdown(body)
    body_html = "\n".join(line.rstrip() for line in body_html.splitlines())
    used_blocks: set[str] = set()
    body_html = body_html.replace(
        'style="list-style-position: inside;"', 'class="project-list"'
    )
    for group in resource_blocks:
        token = f"{{{{resource-block:{group}}}}}"
        if token in body_html:
            body_html = body_html.replace(token, f"<!-- RESOURCE-BLOCK:{group} -->")
            used_blocks.add(group)
    content_sections: list[str] = []
    sections = re.split(r"<!-- RESOURCE-BLOCK:([^>]+) -->", body_html)
    for index, section in enumerate(sections):
        if index % 2 == 0:
            if section.strip():
                content_sections.append(
                    '<div class="proj-txt-container">\n'
                    f"{section}\n"
                    "</div>"
                )
            continue
        content_sections.append(f"<br>\n{resource_blocks[section]}")
    for group, block in resource_blocks.items():
        if group not in used_blocks:
            content_sections.append(f"<br>\n{block}")
    content_html = "\n".join(content_sections)
    if configurations:
        scripts = (
            '<script src="../scripts/image-loader.js"></script>\n'
            "<script>\n"
            f"const imageConfigurations = {json.dumps(configurations, ensure_ascii=False, indent=2)};\n"
            "</script>"
        )
    heading = f"<h2>{html.escape(title)}</h2>" if kind == "project" else f"<p><u>{html.escape(title)}</u></p>"
    page = f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="title" content="Gregory Cotton">
    <meta name="description" content="{html.escape(description, quote=True)}">
    <meta property="og:title" content="{html.escape(title, quote=True)} | Gregory Cotton">
    <meta property="og:description" content="{html.escape(description, quote=True)}">
    <meta property="og:type" content="website">
    <meta name="twitter:title" content="{html.escape(title, quote=True)} | Gregory Cotton">
    <meta name="author" content="Gregory Cotton">
    <meta name="creator" content="gregorycotton.ca">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{html.escape(title)} | Gregory Cotton</title>
    <link rel="stylesheet" href="../style.css">
    <link rel="apple-touch-icon" sizes="180x180" href="../assets/favicon/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="../assets/favicon/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="../assets/favicon/favicon-16x16.png">
    <link rel="manifest" href="../assets/favicon/site.webmanifest">
    {scripts}
</head>
<body>
    <div class="container">
        <div class="left"><h1><a href="{home_url}" class="home-link">Gregory Cotton</a></h1></div>
        <div class="right">
            {heading}
            <br>
            {render_metadata(record)}
            {content_html}
        </div>
    </div>
    {Path(root / 'footer.html').read_text(encoding='utf-8')}
</body>
</html>
'''
    page = "\n".join(line.rstrip() for line in page.splitlines()) + "\n"
    output_path.write_text(page, encoding="utf-8")
    return output_path


def build(source_dir: Path, output_dir: Path, database_path: Path, root: Path) -> list[Path]:
    validator = load_validator()
    count = validator.validate_content(source_dir, root, database_path)
    sources = sorted(source_dir.rglob("*.md"))
    if count != len(sources):
        raise ValueError("content validation count changed during build")
    output_dir.mkdir(parents=True, exist_ok=True)
    generated: list[Path] = []
    with sqlite3.connect(database_path) as database:
        database.row_factory = sqlite3.Row
        for source in sources:
            generated.append(render_page(source, output_dir, root, database, validator))
    manifest = {
        "builder": "build-pages.py",
        "sourceDirectory": str(source_dir.relative_to(root)),
        "pages": [str(path.relative_to(output_dir)).replace("\\", "/") for path in generated],
    }
    (output_dir / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return generated


def self_test(root: Path, database_path: Path) -> None:
    source_dir = root / "content"
    output_dir = root / ".build/pages-self-test"
    generated = build(source_dir, output_dir, database_path, root)
    assert len(generated) == 49
    expected = {
        "ontology/anvil.html",
        "ontology/gregs-fridge.html",
        "ontology/tobys-barbershop.html",
        "fieldnotes/ajuda.html",
    }
    assert expected.issubset({str(path.relative_to(output_dir)) for path in generated})
    for path in generated:
        text = path.read_text(encoding="utf-8")
        assert "server.php" not in text
        assert '<details id="propertiesDetails">' in text
        assert "Gregory Cotton" in text
    anvil = (output_dir / "ontology/anvil.html").read_text(encoding="utf-8")
    assert anvil.count("data-fullimageurl=") == 4
    assert anvil.count("<td id=\"fileSize-") == 4
    assert anvil.count('class="image-loader-table"') == 1
    assert "anvil-homepage.jpg" in anvil
    text_start = anvil.index('<div class="proj-txt-container">')
    text_end = anvil.index("</div>", text_start)
    resource_start = anvil.index('<div class="proj-resource-container">')
    assert text_end < resource_start
    assert anvil.count('class="project-list"') == 1
    assert "list-style-position: inside" not in anvil
    toby = (output_dir / "ontology/tobys-barbershop.html").read_text(encoding="utf-8")
    assert "youtube.com/embed/WYxXBu0DFFA" in toby
    fridge = (output_dir / "ontology/gregs-fridge.html").read_text(encoding="utf-8")
    assert "fridge.gregorycotton.ca" in fridge and "internetphonebook.net" in fridge
    fieldnote = (output_dir / "fieldnotes/ajuda.html").read_text(encoding="utf-8")
    assert "Jardim Botânico da Ajuda" in fieldnote
    print(f"page generator self-tests passed ({len(generated)} pages)")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-dir", type=Path, default=ROOT / "content")
    parser.add_argument("--output-dir", type=Path, default=ROOT / ".build/pages")
    parser.add_argument("--database", type=Path, default=ROOT / "database/projects.db")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test(ROOT, args.database.resolve())
        return 0
    generated = build(args.source_dir.resolve(), args.output_dir.resolve(), args.database.resolve(), ROOT)
    print(f"Generated {len(generated)} pages -> {args.output_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
