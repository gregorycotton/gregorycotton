#!/usr/bin/env python3
"""Check deterministic RSS generation from the static catalogue."""

from __future__ import annotations

import importlib.util
import json
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent


def load_builder():
    path = ROOT / "scripts/build-site.py"
    spec = importlib.util.spec_from_file_location("build_site", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"could not load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main() -> int:
    builder = load_builder()
    catalogue = {
        "views": {
            "ontology": {"rows": [{"UUID": "excluded"}]},
            "fieldnotes": {
                "rows": [
                    {
                        "UUID": "b687f1d2-60e8-491b-9db9-fd9d101e755b",
                        "Title": "Fish & Chips",
                        "ShortDescription": "A <short> description",
                        "PublishedDate": "2026-05-25",
                        "LastUpdated": "2026-07-25",
                        "URL": "café notes",
                    }
                ]
            },
        }
    }
    with tempfile.TemporaryDirectory(prefix="fieldnotes-feed-") as temporary_name:
        temporary = Path(temporary_name)
        catalogue_path = temporary / "catalogue.json"
        feed_path = temporary / "fieldnotes.xml"
        catalogue_path.write_text(json.dumps(catalogue), encoding="utf-8")
        builder.build_fieldnotes_feed(catalogue_path, feed_path)
        first_build = feed_path.read_bytes()
        builder.build_fieldnotes_feed(catalogue_path, feed_path)
        assert feed_path.read_bytes() == first_build

        channel = ET.parse(feed_path).getroot().find("channel")
        assert channel is not None
        items = channel.findall("item")
        assert len(items) == 1
        assert items[0].findtext("guid") == "urn:uuid:b687f1d2-60e8-491b-9db9-fd9d101e755b"
        assert items[0].findtext("description") == "A <short> description"
        assert items[0].findtext("link") == "https://gregorycotton.ca/fieldnotes/caf%C3%A9%20notes.html"
        assert channel.findtext("lastBuildDate") == "Sat, 25 Jul 2026 00:00:00 GMT"
        assert "excluded" not in first_build.decode("utf-8")

    print("fieldnotes feed test passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
