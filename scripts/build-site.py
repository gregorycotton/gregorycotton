#!/usr/bin/env python3
"""Stage, check, or publish the static main-site build for Git deployment."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from email.utils import format_datetime
from pathlib import Path
from urllib.parse import quote


ROOT = Path(__file__).resolve().parent.parent
DEFAULT_STAGE = ROOT / ".build/site"
FOOTER_START = "<!-- GENERATED FOOTER:START -->"
FOOTER_END = "<!-- GENERATED FOOTER:END -->"
SITE_URL = "https://gregorycotton.ca"
FEED_PATH = Path("fieldnotes.xml")
ATOM_NAMESPACE = "http://www.w3.org/2005/Atom"

ET.register_namespace("atom", ATOM_NAMESPACE)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def run(script: str, *arguments: str) -> None:
    command = [sys.executable, str(ROOT / "scripts" / script), *arguments]
    subprocess.run(command, cwd=ROOT, check=True)


def generated_paths(stage: Path) -> set[Path]:
    paths = {Path("index.html"), Path("changelog.html"), FEED_PATH}
    paths.update(path.relative_to(stage) for path in (stage / "ontology").glob("*.html"))
    paths.update(path.relative_to(stage) for path in (stage / "fieldnotes").glob("*.html"))
    return paths


def tracked_generated_paths() -> set[Path]:
    return {
        Path("index.html"),
        Path("changelog.html"),
        FEED_PATH,
        *(path.relative_to(ROOT) for path in (ROOT / "ontology").glob("*.html")),
        *(path.relative_to(ROOT) for path in (ROOT / "fieldnotes").glob("*.html")),
    }


def rss_date(value: str) -> str:
    parsed = datetime.strptime(value, "%Y-%m-%d").replace(tzinfo=timezone.utc)
    return format_datetime(parsed, usegmt=True)


def build_fieldnotes_feed(catalogue_path: Path, output_path: Path) -> None:
    catalogue = json.loads(catalogue_path.read_text(encoding="utf-8"))
    records = catalogue["views"]["fieldnotes"]["rows"]
    rss = ET.Element("rss", {"version": "2.0"})
    channel = ET.SubElement(rss, "channel")
    ET.SubElement(channel, "title").text = "Gregory Cotton — Fieldnotes"
    ET.SubElement(channel, "link").text = f"{SITE_URL}/"
    ET.SubElement(channel, "description").text = "Fieldnotes by Gregory Cotton"
    ET.SubElement(channel, "language").text = "en"
    ET.SubElement(
        channel,
        f"{{{ATOM_NAMESPACE}}}link",
        {
            "href": f"{SITE_URL}/{FEED_PATH}",
            "rel": "self",
            "type": "application/rss+xml",
        },
    )

    for record in records:
        for field in ("UUID", "Title", "PublishedDate", "URL"):
            if not record.get(field):
                raise ValueError(f"fieldnote feed record is missing {field}: {record!r}")

    if records:
        latest = max(record.get("LastUpdated") or record["PublishedDate"] for record in records)
        ET.SubElement(channel, "lastBuildDate").text = rss_date(latest)

    for record in records:
        item_url = f"{SITE_URL}/fieldnotes/{quote(record['URL'], safe='-._~')}.html"
        item = ET.SubElement(channel, "item")
        ET.SubElement(item, "title").text = record["Title"]
        ET.SubElement(item, "link").text = item_url
        ET.SubElement(item, "guid", {"isPermaLink": "false"}).text = f"urn:uuid:{record['UUID']}"
        ET.SubElement(item, "pubDate").text = rss_date(record["PublishedDate"])
        ET.SubElement(item, "description").text = record.get("ShortDescription") or ""

    ET.indent(rss, space="  ")
    output_path.write_bytes(
        ET.tostring(rss, encoding="utf-8", xml_declaration=True) + b"\n"
    )


def inject_footer(path: Path) -> None:
    page = path.read_text(encoding="utf-8")
    pattern = re.compile(
        rf"{re.escape(FOOTER_START)}.*?{re.escape(FOOTER_END)}", re.DOTALL
    )
    if len(pattern.findall(page)) != 1:
        raise ValueError(f"expected one generated footer block in {path}")
    footer = (ROOT / "footer.html").read_text(encoding="utf-8").strip()
    block = f"{FOOTER_START}\n{footer}\n{FOOTER_END}"
    path.write_text(pattern.sub(lambda _match: block, page), encoding="utf-8")


def stage(stage: Path) -> set[Path]:
    if stage == ROOT or ROOT not in stage.parents:
        raise ValueError(f"stage directory must be inside the repository build area: {stage}")
    if stage.exists():
        shutil.rmtree(stage)
    stage.mkdir(parents=True)
    shutil.copy2(ROOT / "index.html", stage / "index.html")
    shutil.copy2(ROOT / "changelog.html", stage / "changelog.html")
    run("build-pages.py", "--output-dir", str(stage))
    run(
        "build-catalogue.py",
        "--output-dir",
        str(stage / "catalogue"),
        "--homepage",
        str(stage / "index.html"),
        "--page-root",
        str(stage),
    )
    build_fieldnotes_feed(stage / "catalogue/catalogue.json", stage / FEED_PATH)
    inject_footer(stage / "index.html")
    inject_footer(stage / "changelog.html")
    paths = generated_paths(stage)
    manifest = {
        "builder": "build-site.py",
        "trackedDeploymentPaths": sorted(path.as_posix() for path in paths),
        "sha256": {path.as_posix(): sha256_file(stage / path) for path in sorted(paths)},
    }
    (stage / "site-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return paths


def compare_with_tracked(stage_dir: Path, paths: set[Path]) -> list[str]:
    mismatches: list[str] = []
    tracked_paths = tracked_generated_paths()
    if tracked_paths != paths:
        missing = sorted(str(path) for path in paths - tracked_paths)
        extra = sorted(str(path) for path in tracked_paths - paths)
        if missing:
            mismatches.append(f"generated paths not present in the repository: {', '.join(missing)}")
        if extra:
            mismatches.append(f"repository pages have no Markdown source: {', '.join(extra)}")
    for path in sorted(paths):
        current = ROOT / path
        generated = stage_dir / path
        if not current.is_file() or current.read_bytes() != generated.read_bytes():
            mismatches.append(str(path))
    return mismatches


def publish(stage_dir: Path, paths: set[Path]) -> None:
    legacy_snapshot = ROOT / ".build/legacy-pages"
    if not legacy_snapshot.exists():
        legacy_snapshot.mkdir(parents=True)
        shutil.copytree(ROOT / "ontology", legacy_snapshot / "ontology")
        shutil.copytree(ROOT / "fieldnotes", legacy_snapshot / "fieldnotes")
    stale_paths = tracked_generated_paths() - paths
    for path in sorted(paths):
        destination = ROOT / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(stage_dir / path, destination)
    for path in sorted(stale_paths):
        (ROOT / path).unlink()
        print(f"Removed stale generated page: {path}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="stage a build and fail if tracked output is stale")
    mode.add_argument("--publish", action="store_true", help="stage a build and copy generated pages into tracked paths")
    parser.add_argument("--stage-dir", type=Path, default=DEFAULT_STAGE)
    args = parser.parse_args()
    stage_dir = args.stage_dir.resolve()
    try:
        paths = stage(stage_dir)
        if args.check:
            mismatches = compare_with_tracked(stage_dir, paths)
            if mismatches:
                print("Static build is stale. Run `python3 scripts/build-site.py --publish` before pushing.", file=sys.stderr)
                print("Mismatched paths:", file=sys.stderr)
                print("\n".join(mismatches), file=sys.stderr)
                return 1
            print(f"Static build check passed ({len(paths)} deployment files)")
        elif args.publish:
            publish(stage_dir, paths)
            print(f"Published {len(paths)} generated deployment files into tracked paths")
        else:
            print(f"Static build staged at {stage_dir} ({len(paths)} deployment files)")
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"Static site build failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
