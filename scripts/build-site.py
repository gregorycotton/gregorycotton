#!/usr/bin/env python3
"""Stage, check, or publish the static main-site build for Git deployment."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
DEFAULT_STAGE = ROOT / ".build/site"


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
    paths = {Path("index.html")}
    paths.update(path.relative_to(stage) for path in (stage / "ontology").glob("*.html"))
    paths.update(path.relative_to(stage) for path in (stage / "fieldnotes").glob("*.html"))
    return paths


def stage(stage: Path) -> set[Path]:
    if stage == ROOT or ROOT not in stage.parents:
        raise ValueError(f"stage directory must be inside the repository build area: {stage}")
    if stage.exists():
        shutil.rmtree(stage)
    stage.mkdir(parents=True)
    shutil.copy2(ROOT / "index.html", stage / "index.html")
    run(
        "build-catalogue.py",
        "--output-dir",
        str(stage / "catalogue"),
        "--homepage",
        str(stage / "index.html"),
    )
    run("build-pages.py", "--output-dir", str(stage))
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
    tracked_paths = {
        Path("index.html"),
        *(path.relative_to(ROOT) for path in (ROOT / "ontology").glob("*.html")),
        *(path.relative_to(ROOT) for path in (ROOT / "fieldnotes").glob("*.html")),
    }
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
    for path in sorted(paths):
        destination = ROOT / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(stage_dir / path, destination)


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
