#!/usr/bin/env bash
# Create projects/<slug>/ from _template.
# Usage: new_project.sh <slug> ["Display Name"] [--mode compose|hand]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SLUG="${1:-}"
shift || true
NAME="$SLUG"
MODE="compose"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) MODE="${2:?}"; shift 2 ;;
    *) NAME="$1"; shift ;;
  esac
done
if [[ -z "$SLUG" ]]; then
  echo "Usage: new_project.sh <slug> [\"Display Name\"] [--mode compose|hand]" >&2
  exit 1
fi
DEST="$ROOT/projects/$SLUG"
if [[ -e "$DEST" ]]; then
  echo "Already exists: $DEST" >&2
  exit 1
fi
mkdir -p "$DEST"
cp -R "$ROOT/projects/_template/." "$DEST/"
# rewrite project.yaml
python3 - "$DEST/project.yaml" "$SLUG" "$NAME" "$MODE" <<'PY'
import sys
from pathlib import Path
path, slug, name, mode = sys.argv[1:5]
text = Path(path).read_text()
text = text.replace("<Project Name>", name).replace("<slug>", slug).replace("<mode>", mode)
Path(path).write_text(text)
PY
if [[ "$MODE" == "compose" ]]; then
  mkdir -p "$DEST/slides" "$DEST/assets" "$DEST/dist"
  cp "$ROOT/templates/deck.yaml.example" "$DEST/deck.yaml"
  cp "$ROOT/templates/slides/"*.html "$DEST/slides/" 2>/dev/null || true
else
  mkdir -p "$DEST/assets"
  rm -f "$DEST/deck.yaml"
  echo "Hand mode: place or symlink index.html under $DEST (or set root_dir in project.yaml)"
fi
echo "Created $DEST (mode=$MODE)"
