#!/usr/bin/env python3
"""Import existing project/fieldnote HTML into Markdown source files."""

from __future__ import annotations

import argparse
import html
import json
import posixpath
from dataclasses import dataclass, field
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse


ROOT = Path(__file__).resolve().parent.parent
VOID_TAGS = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"}


@dataclass
class Node:
    tag: str | None
    attrs: dict[str, str] = field(default_factory=dict)
    children: list["Node | str"] = field(default_factory=list)


class TreeParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=False)
        self.root = Node(None)
        self.stack = [self.root]

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        node = Node(tag, {name: value or "" for name, value in attrs})
        self.stack[-1].children.append(node)
        if tag not in VOID_TAGS:
            self.stack.append(node)

    def handle_startendtag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        self.stack[-1].children.append(Node(tag, {name: value or "" for name, value in attrs}))

    def handle_endtag(self, tag: str) -> None:
        for index in range(len(self.stack) - 1, 0, -1):
            if self.stack[index].tag == tag:
                del self.stack[index:]
                return

    def handle_data(self, data: str) -> None:
        self.stack[-1].children.append(data)

    def handle_entityref(self, name: str) -> None:
        self.handle_data(f"&{name};")

    def handle_charref(self, name: str) -> None:
        self.handle_data(f"&#{name};")

    def handle_comment(self, data: str) -> None:
        self.handle_data(f"<!--{data}-->")


def parse(path: Path) -> Node:
    parser = TreeParser()
    parser.feed(path.read_text(encoding="utf-8"))
    parser.close()
    return parser.root


def elements(node: Node):
    for child in node.children:
        if isinstance(child, Node):
            yield child


def descendants(node: Node):
    for child in elements(node):
        yield child
        yield from descendants(child)


def first(node: Node, predicate) -> Node | None:
    return next((item for item in descendants(node) if predicate(item)), None)


def classes(node: Node) -> set[str]:
    return set(node.attrs.get("class", "").split())


def inner_html(node: Node) -> str:
    return "".join(serialize(child) for child in node.children)


def serialize(node: Node | str) -> str:
    if isinstance(node, str):
        return node
    if node.tag is None:
        return inner_html(node)
    attributes = "".join(
        f' {name}="{html.escape(value, quote=True)}"' for name, value in node.attrs.items()
    )
    if node.tag in VOID_TAGS:
        return f"<{node.tag}{attributes}>"
    return f"<{node.tag}{attributes}>{inner_html(node)}</{node.tag}>"


def text_content(node: Node) -> str:
    return "".join(child if isinstance(child, str) else text_content(child) for child in node.children)


def page_rel_path(page: Path, root: Path) -> str:
    return page.relative_to(root).as_posix()


def repo_path_from_page_url(value: str, page_rel: str) -> str:
    parsed = urlparse(value)
    if parsed.scheme in {"http", "https"}:
        return value
    if value.startswith("/"):
        return value.lstrip("/")
    return posixpath.normpath(posixpath.join(posixpath.dirname(page_rel), value))


def toml_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def resource_from_table(table: Node, page_rel: str, block_name: str) -> list[dict]:
    resources: list[dict] = []
    for row in descendants(table):
        if row.tag != "tr":
            continue
        cells = [child for child in elements(row) if child.tag == "td"]
        if len(cells) < 4:
            continue
        image = first(cells[0], lambda node: node.tag == "img")
        trigger = cells[3] if "loadImageTrigger" in classes(cells[3]) else first(cells[3], lambda node: "loadImageTrigger" in classes(node))
        if image is None or trigger is None:
            continue
        file_path = trigger.attrs.get("data-fullimageurl", "")
        thumbnail_path = image.attrs.get("src", "")
        if not file_path or not thumbnail_path:
            raise ValueError(f"image row in {page_rel} is missing a full or thumbnail path")
        title = trigger.attrs.get("data-title") or text_content(cells[1]).strip()
        alt = image.attrs.get("alt") or f"{title} thumbnail"
        resources.append(
            {
                "type": "image",
                "group": block_name,
                "title": title,
                "file": repo_path_from_page_url(file_path, page_rel),
                "thumbnail": repo_path_from_page_url(thumbnail_path, page_rel),
                "alt": alt,
            }
        )
    return resources


def resource_from_iframe(container: Node, block_name: str) -> list[dict]:
    iframe = first(container, lambda node: node.tag == "iframe")
    if iframe is None or not iframe.attrs.get("src"):
        return []
    url = iframe.attrs["src"]
    resource_type = "embed" if "youtube.com/" in url or "youtu.be/" in url else "iframe"
    resource = {
        "type": resource_type,
        "group": block_name,
        "title": iframe.attrs.get("title") or "Embedded content",
        "url": url,
    }
    for name in ("width", "height", "style"):
        if name in iframe.attrs:
            value = iframe.attrs[name]
            resource[name] = int(value) if name in {"width", "height"} and value.isdigit() else value
    if resource_type == "embed":
        resource["provider"] = "youtube"
    return [resource]


def extract_resource_container(container: Node, page_rel: str, block_index: int) -> tuple[list[dict], list[str], int]:
    block_name = f"block-{block_index}"
    table = first(container, lambda node: node.tag == "table" and "image-loader-table" in classes(node))
    block_resources = resource_from_table(table, page_rel, block_name) if table else resource_from_iframe(container, block_name)
    if not block_resources:
        raw = serialize(container).strip()
        return [], [raw] if raw else [], block_index

    body_parts = [f"{{{{resource-block:{block_name}}}}}"]
    resources = list(block_resources)
    next_index = block_index + 1
    for child in elements(container):
        if child.tag == "div" and "table-container" in classes(child) and first(child, lambda node: node.tag == "table") is table:
            continue
        if child.tag == "div" and "image-display-area" in classes(child):
            continue
        if child.tag == "div" and "proj-txt-container" in classes(child):
            content = inner_html(child).strip()
            if content:
                body_parts.append(content)
        elif child.tag == "div" and "proj-resource-container" in classes(child):
            nested_resources, nested_parts, next_index = extract_resource_container(child, page_rel, next_index)
            resources.extend(nested_resources)
            body_parts.extend(nested_parts)
        elif child.tag == "br":
            body_parts.append("<br>")
    return resources, body_parts, next_index


def extract_source(page: Path, root: Path) -> tuple[str, str, str, str, list[dict], str]:
    page_rel = page_rel_path(page, root)
    kind = "project" if page.parent.name == "ontology" else "fieldnote"
    slug = page.stem
    tree = parse(page)
    right = first(tree, lambda node: node.tag == "div" and "right" in classes(node))
    if right is None:
        raise ValueError(f"{page_rel} has no .right page container")

    body_parts: list[str] = []
    resources: list[dict] = []
    block_index = 0
    display_title = ""
    for child in elements(right):
        if child.tag == "details" and child.attrs.get("id") == "propertiesDetails":
            continue
        if child.tag == "h2":
            display_title = html.unescape(text_content(child).strip())
            continue
        if child.tag == "p" and first(child, lambda node: node.tag == "u") is not None:
            display_title = html.unescape(text_content(child).strip())
            continue
        if child.tag == "div" and "proj-txt-container" in classes(child):
            content = inner_html(child).strip()
            if content:
                body_parts.append(content)
            continue
        if child.tag == "div" and "proj-resource-container" in classes(child):
            block_resources, block_parts, block_index = extract_resource_container(child, page_rel, block_index)
            resources.extend(block_resources)
            body_parts.extend(block_parts)
            continue
        if child.tag == "br":
            body_parts.append("<br>")

    return kind, slug, display_title, "custom", resources, "\n\n".join(body_parts).strip()


def write_front_matter(kind: str, slug: str, display_title: str, template: str, resources: list[dict], body: str) -> str:
    lines = ["+++", f"kind = {toml_string(kind)}", f"slug = {toml_string(slug)}", f"template = {toml_string(template)}"]
    if display_title:
        lines.insert(3, f"display_title = {toml_string(display_title)}")
    for resource in resources:
        lines.append("")
        lines.append("[[resources]]")
        for field_name, value in resource.items():
            if isinstance(value, int):
                lines.append(f"{field_name} = {value}")
            else:
                lines.append(f"{field_name} = {toml_string(str(value))}")
    lines.extend(["+++", body, ""])
    return "\n".join(lines)


def import_pages(root: Path, output_dir: Path) -> list[Path]:
    pages = sorted(root.joinpath("ontology").glob("*.html")) + sorted(root.joinpath("fieldnotes").glob("*.html"))
    written: list[Path] = []
    for page in pages:
        kind, slug, display_title, template, resources, body = extract_source(page, root)
        destination = output_dir / ("projects" if kind == "project" else "fieldnotes") / f"{slug}.md"
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(write_front_matter(kind, slug, display_title, template, resources, body), encoding="utf-8")
        written.append(destination)
    return written


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, default=ROOT / "content")
    args = parser.parse_args()
    written = import_pages(ROOT, args.output_dir.resolve())
    print(f"Imported {len(written)} legacy pages into {args.output_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
