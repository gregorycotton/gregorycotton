#!/usr/bin/env python3
"""Verify the four migrated outward-link tables retain their public content."""

from __future__ import annotations

import importlib.util
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
EXPECTED = {
    "amplify": [
        ("App. A – Amplify onboarding flow", "Figma prototype", "https://www.figma.com/proto/RvDV1HXuxTtjDsS9pB5tN1/Amplify-Digital-Civic-Engagement-*?page-id=1310%3A2971&node-id=1310%3A3280&viewport=1566%2C784%2C0.13&scaling=min-zoom&starting-point-node-id=1310%3A3280&show-proto-sidebar=1", "New tab"),
        ("App. B – Amplify map functionality", "Figma prototype", "https://www.figma.com/proto/RvDV1HXuxTtjDsS9pB5tN1/Amplify-Digital-Civic-Engagement-*?page-id=1310%3A2971&node-id=1329%3A3469&viewport=777%2C529%2C0.05&scaling=min-zoom&starting-point-node-id=1329%3A3469&show-proto-sidebar=1", "New tab"),
    ],
    "myoap-dashboard": [
        ("App. A – Connect a profile", "Figma prototype", "https://www.figma.com/proto/iWkpPgxH7mhY3BZvMDntdF/Ontario-Autism-Program-Client-Portal-*?page-id=3937%3A17026&node-id=3937%3A17194&viewport=1641%2C1875%2C0.46&scaling=scale-down&starting-point-node-id=3937%3A17194&show-proto-sidebar=1", "New tab"),
        ("App. B – Register online", "Figma prototype", "https://www.figma.com/proto/iWkpPgxH7mhY3BZvMDntdF/Ontario-Autism-Program-Client-Portal-*?page-id=3937%3A17026&node-id=3961%3A17993&viewport=1641%2C1875%2C0.46&scaling=scale-down&starting-point-node-id=3961%3A17993&show-proto-sidebar=1", "New tab"),
        ("App. C – Add a new expense", "Figma prototype", "https://www.figma.com/proto/iWkpPgxH7mhY3BZvMDntdF/Ontario-Autism-Program-Client-Portal-*?page-id=3937%3A17026&node-id=3937%3A18715&viewport=1641%2C1875%2C0.46&scaling=scale-down&starting-point-node-id=3937%3A18715&show-proto-sidebar=1", "New tab"),
    ],
    "public-secure-sso": [
        ("App. A – High-level onboarding", "Figma prototype", "https://www.figma.com/proto/xvq1qPbkntspGvmuqqvF4x/Public-Secure-SSO-*?page-id=4138%3A9629&node-id=4139%3A9629&viewport=623%2C319%2C0.07&scaling=min-zoom&starting-point-node-id=4139%3A9629&show-proto-sidebar=1", "New tab"),
        ("App. B – Low-level sign-on", "Figma prototype", "https://www.figma.com/proto/xvq1qPbkntspGvmuqqvF4x/Public-Secure-SSO-*?page-id=4138%3A9629&node-id=4139%3A10434&viewport=623%2C319%2C0.07&scaling=min-zoom&starting-point-node-id=4139%3A10434&show-proto-sidebar=1", "New tab"),
        ("App. C – Password reset", "Figma prototype", "https://www.figma.com/proto/xvq1qPbkntspGvmuqqvF4x/Public-Secure-SSO-*?page-id=4138%3A9629&node-id=4139%3A10763&viewport=623%2C319%2C0.07&scaling=min-zoom&starting-point-node-id=4139%3A10763&show-proto-sidebar=1", "New tab"),
        ("App. D – Account migration", "Figma prototype", "https://www.figma.com/proto/xvq1qPbkntspGvmuqqvF4x/Public-Secure-SSO-*?page-id=4138%3A9629&node-id=4139%3A11213&viewport=623%2C319%2C0.07&scaling=min-zoom&starting-point-node-id=4139%3A11213&show-proto-sidebar=1", "New tab"),
        ("App. E – Account management", "Figma prototype", "https://www.figma.com/proto/xvq1qPbkntspGvmuqqvF4x/Public-Secure-SSO-*?page-id=4138%3A9629&node-id=4139%3A11880&viewport=623%2C319%2C0.07&scaling=min-zoom&starting-point-node-id=4139%3A11880&show-proto-sidebar=1", "New tab"),
    ],
    "the-food-library": [
        ("App. A – Owen on the food scanner", "YouTube video", "https://youtu.be/-L34Hf1YKnI?si=HJQWKf8s0m3mPGet", "New tab"),
        ("App. B – Food scanner prototype", "XD prototype", "https://xd.adobe.com/view/0cc0377d-1be6-4e04-65c0-65b2421c1e70-7af1/", "New tab"),
        ("App. C – Owen on the preserves shelves", "YouTube video", "https://youtu.be/mlkj0GzIXH4?si=5M0zUIT2aPRMoGnI", "New tab"),
        ("App. D – Library menu prototype", "XD prototype", "https://xd.adobe.com/view/49bd72bc-e1e6-4155-4cf6-abd5917f1a55-3f8c/", "New tab"),
        ("App. E – Owen on the seed exchange", "YouTube video", "https://www.youtube.com/watch?v=_9GV0xO6asg", "New tab"),
        ("App. F – Seed database prototype", "XD prototype", "https://xd.adobe.com/view/2fc19bad-b2a2-4a29-47e8-0d2da5f27245-59f0/", "New tab"),
    ],
}


def load_validator():
    path = ROOT / "scripts/validate-content.py"
    spec = importlib.util.spec_from_file_location("content_validator", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"could not load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main() -> int:
    validator = load_validator()
    total = 0
    for slug, expected in EXPECTED.items():
        metadata, body = validator.parse_page(ROOT / f"content/projects/{slug}.md")
        links = [resource for resource in metadata["resources"] if resource["type"] == "link"]
        actual = [
            (resource["title"], resource["link_type"], resource["url"], resource["action"])
            for resource in links
        ]
        assert actual == expected, f"migrated links changed for {slug}"
        groups = {resource["group"] for resource in links}
        assert len(groups) == 1 and f"{{{{resource-block:{groups.pop()}}}}}" in body
        assert "image-loader-table" not in body and 'id="projectsTable"' not in body
        total += len(links)
    assert total == 16
    print("resource migration self-tests passed (16 links)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
