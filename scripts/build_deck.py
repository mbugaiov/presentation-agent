#!/usr/bin/env python3
"""Assemble a Calliope compose-mode deck into dist/index.html."""
from __future__ import annotations

import argparse
import os
import re
import shutil
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None


def load_deck(path: Path) -> dict:
    text = path.read_text()
    if yaml is not None:
        return yaml.safe_load(text) or {}
    # Minimal YAML subset: key: value and slides: list of {file: ...}
    data: dict = {"slides": []}
    current = None
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("- "):
            item = line[2:].strip()
            if item.startswith("file:"):
                data.setdefault("slides", []).append({"file": item.split(":", 1)[1].strip().strip('"')})
            continue
        if ":" in line and not line.startswith(" "):
            k, _, v = line.partition(":")
            k, v = k.strip(), v.strip().strip('"').strip("'")
            if k == "slides":
                current = "slides"
                continue
            data[k] = v
    return data


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--project", required=True, type=Path)
    ap.add_argument("--engine", type=Path, default=None)
    args = ap.parse_args()
    proj = args.project.resolve()
    engine = (args.engine or Path(__file__).resolve().parents[1]).resolve()

    deck_path = proj / "deck.yaml"
    if not deck_path.is_file():
        raise SystemExit(f"Missing {deck_path} (compose mode)")

    meta = load_deck(deck_path)
    title = meta.get("title") or "Calliope deck"
    brand = meta.get("brand") or "CALLIOPE"
    footer = meta.get("footer") or brand

    slides_html: list[str] = []
    for entry in meta.get("slides") or []:
        if isinstance(entry, str):
            rel = entry
        else:
            rel = entry.get("file") or entry.get("path")
        if not rel:
            continue
        sp = proj / rel
        if not sp.is_file():
            raise SystemExit(f"Missing slide: {sp}")
        body = sp.read_text().strip()
        if not body.startswith("<section"):
            body = f"<section>\n{body}\n</section>"
        slides_html.append(body)

    shell = (engine / "theme" / "shell.html").read_text()
    out_dir = proj / "dist"
    out_dir.mkdir(parents=True, exist_ok=True)
    # Copy theme assets next to index for portable serve
    shutil.copy2(engine / "theme" / "calliope.css", out_dir / "calliope.css")
    shutil.copy2(engine / "theme" / "boot.js", out_dir / "boot.js")
    # Project assets/
    assets_src = proj / "assets"
    if assets_src.is_dir():
        dest = out_dir / "assets"
        if dest.exists():
            shutil.rmtree(dest)
        shutil.copytree(assets_src, dest)

    html = (
        shell.replace("{{TITLE}}", title)
        .replace("{{BRAND}}", brand)
        .replace("{{FOOTER}}", footer)
        .replace("{{THEME_HREF}}", "calliope.css")
        .replace("{{BOOT_HREF}}", "boot.js")
        .replace("{{SLIDES}}", "\n\n".join(slides_html))
    )
    # Soft-check: forbid absolute personal paths leaking into output
    if re.search(r"/Users/[^\"'\s]+", html):
        raise SystemExit("Refusing to write deck with absolute /Users/ paths in HTML")

    (out_dir / "index.html").write_text(html)
    print(f"Built {out_dir / 'index.html'} ({len(slides_html)} slides)")


if __name__ == "__main__":
    main()
