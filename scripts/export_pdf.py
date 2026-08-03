#!/usr/bin/env python3
"""Export reveal.js deck to PDF via Playwright (print-pdf layout)."""
from __future__ import annotations

import argparse
import http.server
import threading
import time
from pathlib import Path


def start_server(directory: Path, port: int) -> http.server.HTTPServer:
    handler = lambda *args, **kwargs: http.server.SimpleHTTPRequestHandler(  # noqa: E731
        *args, directory=str(directory), **kwargs
    )
    server = http.server.HTTPServer(("127.0.0.1", port), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    time.sleep(0.4)
    return server


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", type=Path, default=Path("."))
    ap.add_argument("--html", default="index.html")
    ap.add_argument("--out", default="deck.pdf")
    ap.add_argument("--port", type=int, default=8765)
    # positional fallbacks for legacy: export_pdf.py [html] [out]
    ap.add_argument("legacy_html", nargs="?", default=None)
    ap.add_argument("legacy_out", nargs="?", default=None)
    args = ap.parse_args()

    directory = args.dir.resolve()
    html_name = args.legacy_html or args.html
    out_name = args.legacy_out or args.out
    html_path = directory / html_name
    if not html_path.is_file():
        raise SystemExit(f"Missing {html_path}")
    out_path = Path(out_name)
    if not out_path.is_absolute():
        out_path = directory / out_path

    url = f"http://127.0.0.1:{args.port}/{html_name}?print-pdf"
    server = start_server(directory, args.port)

    try:
        from playwright.sync_api import sync_playwright
    except ImportError as exc:
        raise SystemExit(
            "Playwright required: pip install playwright && python3 -m playwright install chromium"
        ) from exc

    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)
            page = browser.new_page(viewport={"width": 1280, "height": 720})
            page.goto(url, wait_until="load", timeout=120_000)
            page.wait_for_selector(".reveal .slides section", timeout=120_000)
            page.wait_for_selector(".reveal.ready", timeout=120_000)
            page.wait_for_timeout(500)
            page.evaluate(
                """async () => {
                  try { await document.fonts.ready; } catch {}
                  if (window.renderAllMermaidForPrint) {
                    await window.renderAllMermaidForPrint();
                  }
                }"""
            )
            page.wait_for_timeout(1500)
            page.pdf(
                path=str(out_path),
                width="13.333in",
                height="7.5in",
                print_background=True,
                margin={"top": "0", "right": "0", "bottom": "0", "left": "0"},
            )
            browser.close()
    finally:
        server.shutdown()

    print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()
