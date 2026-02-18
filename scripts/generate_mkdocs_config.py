#!/usr/bin/env python
"""
Generate mkdocs.yml from mkdocs.base.yml and the docs/ tree.

Rules:
- Use mkdocs.base.yml for all top-level settings (site_name, theme, etc.).
- Build nav automatically from markdown files under docs/:
  - Grouped by first-level directory under docs/ (e.g. UTILS).
  - Files directly under docs/ go at the top level after Home.
  - Within each group, pages are sorted by relative path.
  - Titles are taken from the first H1 in the file; fallback is a title-cased filename.
"""

from __future__ import annotations

import pathlib
from collections import defaultdict, OrderedDict

import yaml

REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
DOCS_DIR = REPO_ROOT / "docs"
BASE_CONFIG_PATH = REPO_ROOT / "mkdocs.base.yml"
OUTPUT_CONFIG_PATH = REPO_ROOT / "mkdocs.yml"


def to_title_case(slug: str) -> str:
    slug = slug.replace("_", " ").replace("-", " ")
    return " ".join(s.capitalize() for s in slug.split())


def page_title(path: pathlib.Path) -> str:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return to_title_case(path.stem)

    for line in text.splitlines():
        if line.startswith("# "):
            return line.lstrip("#").strip()
    return to_title_case(path.stem)


def build_nav() -> list:
    """
    Return a MkDocs nav list.
    - Ensures Home: index.md (if present) is first.
    - Then any other top-level docs/*.md.
    - Then grouped sections per first-level folder under docs/.
    """
    groups: dict[str, list[pathlib.Path]] = defaultdict(list)

    for md_path in sorted(DOCS_DIR.rglob("*.md")):
        rel = md_path.relative_to(DOCS_DIR)
        parts = rel.parts

        if rel.name == "index.md" and len(parts) == 1:
            # Handled explicitly as Home.
            continue

        if len(parts) == 1:
            # Direct child of docs/
            groups["."].append(rel)
        else:
            category = parts[0]
            groups[category].append(rel)

    nav: list = []

    # Home first (if docs/index.md exists)
    index_path = DOCS_DIR / "index.md"
    if index_path.exists():
        nav.append({"Home": "index.md"})

    # Top-level docs/*.md (excluding index.md)
    for rel in sorted(groups.get(".", [])):
        title = page_title(DOCS_DIR / rel)
        nav.append({title: str(rel).replace("\\", "/")})

    # Folder-based groups
    for category in sorted(k for k in groups.keys() if k != "."):
        pretty_category = to_title_case(category)
        children = []
        for rel in sorted(groups[category]):
            title = page_title(DOCS_DIR / rel)
            children.append({title: str(rel).replace("\\", "/")})

        nav.append({pretty_category: children})

    return nav


def main() -> None:
    if not BASE_CONFIG_PATH.exists():
        raise SystemExit(f"Base config not found: {BASE_CONFIG_PATH}")
    if not DOCS_DIR.is_dir():
        raise SystemExit(f"Docs directory not found: {DOCS_DIR}")

    with BASE_CONFIG_PATH.open("r", encoding="utf-8") as f:
        base_cfg = yaml.safe_load(f) or {}

    base_cfg = dict(base_cfg)  # ensure mutable
    base_cfg["nav"] = build_nav()

    with OUTPUT_CONFIG_PATH.open("w", encoding="utf-8") as f:
        yaml.safe_dump(base_cfg, f, sort_keys=False, allow_unicode=True)


if __name__ == "__main__":
    main()

