#!/usr/bin/env python3
"""Assert every non-draft post's translationKey exists in both content/en and content/pt.

Usage: python3 scripts/check_translations.py <content-dir>
Exit 0 on a complete mirror, 1 (with a listing) otherwise.
Stdlib only — no PyYAML; front matter is parsed with a line regex, which is
sufficient for the flat keys this site uses (translationKey, draft).
"""
import re
import sys
from pathlib import Path

FRONT_MATTER = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
KEY_VALUE = re.compile(r"^(\w+):\s*(.*)$")


def parse_front_matter(path: Path) -> dict:
    match = FRONT_MATTER.match(path.read_text(encoding="utf-8"))
    if not match:
        sys.exit(f"ERROR: {path}: missing YAML front matter")
    fields = {}
    for line in match.group(1).splitlines():
        kv = KEY_VALUE.match(line)
        if kv:
            fields[kv.group(1)] = kv.group(2).strip().strip('"').strip("'")
    return fields


SECTION = {"en": "writing", "pt": "artigos"}


def collect_keys(content_dir: Path, lang: str) -> dict:
    """Map translationKey -> post path for non-draft posts in one language."""
    keys = {}
    posts_dir = content_dir / lang / SECTION[lang]
    for post in sorted(posts_dir.glob("*.md")) if posts_dir.is_dir() else []:
        if post.name == "_index.md":
            continue
        fm = parse_front_matter(post)
        if fm.get("draft", "false").lower() == "true":
            continue
        key = fm.get("translationKey", "")
        if not key:
            sys.exit(f"ERROR: {post}: non-draft post has no translationKey")
        if key in keys:
            sys.exit(f"ERROR: duplicate translationKey '{key}' in {lang}: {post} and {keys[key]}")
        keys[key] = post
    return keys


def main() -> None:
    content = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("content")
    en, pt = collect_keys(content, "en"), collect_keys(content, "pt")
    problems = [f"EN post {en[k]} has no PT pair (translationKey: {k})" for k in sorted(en.keys() - pt.keys())]
    problems += [f"PT post {pt[k]} has no EN pair (translationKey: {k})" for k in sorted(pt.keys() - en.keys())]
    if problems:
        print("Translation mirror check FAILED:")
        for problem in problems:
            print(f"  - {problem}")
        sys.exit(1)
    print(f"Translation mirror check OK: {len(en)} post pair(s).")


if __name__ == "__main__":
    main()
