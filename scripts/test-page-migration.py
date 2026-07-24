#!/usr/bin/env python3
"""Compare generated page features with the preserved legacy HTML pages."""

from __future__ import annotations

import argparse
import html
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent


def feature_signature(text: str) -> dict:
    title = re.search(r"<title>(.*?)</title>", text, re.DOTALL)
    return {
        "title": html.unescape(title.group(1).strip()) if title else "",
        "images": re.findall(r'data-fullimageurl="([^"]+)"', text),
        "iframes": [html.unescape(value) for value in re.findall(r'<iframe\b[^>]*\bsrc="([^"]+)"', text)],
        "image_rows": len(re.findall(r'class="loadImageTrigger"', text)),
        "resource_containers": len(re.findall(r'class="proj-resource-container"', text)),
    }


def compare(root: Path, generated_dir: Path, legacy_dir: Path) -> int:
    pages = sorted(legacy_dir.joinpath("ontology").glob("*.html")) + sorted(legacy_dir.joinpath("fieldnotes").glob("*.html"))
    failures: list[str] = []
    for legacy in pages:
        relative = legacy.relative_to(legacy_dir)
        generated = generated_dir / relative
        if not generated.is_file():
            failures.append(f"missing generated page: {relative}")
            continue
        legacy_text = legacy.read_text(encoding="utf-8")
        generated_text = generated.read_text(encoding="utf-8")
        if "server.php" in generated_text:
            failures.append(f"runtime API reference remains: {relative}")
        if feature_signature(legacy_text) != feature_signature(generated_text):
            failures.append(f"feature signature mismatch: {relative}")

    generated_pages = sorted(generated_dir.joinpath("ontology").glob("*.html")) + sorted(generated_dir.joinpath("fieldnotes").glob("*.html"))
    if len(generated_pages) != len(pages):
        failures.append(f"generated page count mismatch: {len(generated_pages)} != {len(pages)}")
    if failures:
        print("page migration comparison failed")
        print("\n".join(failures))
        return 1
    print(f"page migration comparison passed ({len(pages)} pages)")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--generated-dir", type=Path, default=ROOT / ".build/pages-migrated")
    parser.add_argument("--legacy-dir", type=Path, default=ROOT / ".build/legacy-pages")
    args = parser.parse_args()
    legacy_dir = args.legacy_dir.resolve()
    if not legacy_dir.is_dir():
        legacy_dir = ROOT
    return compare(ROOT, args.generated_dir.resolve(), legacy_dir)


if __name__ == "__main__":
    raise SystemExit(main())
