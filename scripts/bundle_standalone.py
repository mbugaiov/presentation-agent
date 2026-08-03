#!/usr/bin/env python3
"""Embed local assets/ images as data URLs into a standalone HTML file."""
from __future__ import annotations

import argparse
import base64
import mimetypes
import re
from pathlib import Path


IMG_RE = re.compile(
    r'(src=["\'])(assets/[^"\']+)(["\'])',
    re.IGNORECASE,
)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", type=Path, default=Path("."))
    ap.add_argument("--html", default="index.html")
    ap.add_argument("--out", default="index-standalone.html")
    args = ap.parse_args()
    directory = args.dir.resolve()
    src = directory / args.html
    if not src.is_file():
        raise SystemExit(f"Missing {src}")
    html = src.read_text()

    def repl(m: re.Match[str]) -> str:
        rel = m.group(2)
        path = directory / rel
        if not path.is_file():
            return m.group(0)
        mime = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
        b64 = base64.b64encode(path.read_bytes()).decode("ascii")
        return f'{m.group(1)}data:{mime};base64,{b64}{m.group(3)}'

    out_html = IMG_RE.sub(repl, html)
    out = directory / args.out
    out.write_text(out_html)
    print(f"Wrote {out} ({out.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    main()
