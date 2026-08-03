#!/usr/bin/env bash
# Calliope CLI — project-scoped deck ops.
# Usage: calliope.sh <slug> <build|serve|pdf|bundle|shell|new>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SLUG="${1:?usage: $0 <slug> <command>}"
CMD="${2:?usage: $0 <slug> <command>}"
shift 2 || true
PROJ="$ROOT/projects/$SLUG"
PY="${PYTHON312:-/opt/homebrew/opt/python@3.12/bin/python3.12}"
command -v "$PY" >/dev/null 2>&1 || PY="python3"

if [[ ! -d "$PROJ" && "$CMD" != "new" ]]; then
  # Allow examples/<slug> for demos
  if [[ -d "$ROOT/examples/$SLUG" ]]; then
    PROJ="$ROOT/examples/$SLUG"
  else
    echo "Missing project: $ROOT/projects/$SLUG" >&2
    exit 1
  fi
fi

export CALLIOPE_PROJECT_DIR="$PROJ"
export CALLIOPE_ENGINE_ROOT="$ROOT"

mode_from_yaml() {
  if [[ -f "$PROJ/project.yaml" ]]; then
    "$PY" - "$PROJ/project.yaml" <<'PY'
import sys
from pathlib import Path
text = Path(sys.argv[1]).read_text()
for line in text.splitlines():
    if line.strip().startswith("mode:"):
        print(line.split(":",1)[1].strip().strip('"').strip("'"))
        break
else:
    print("compose" if (Path(sys.argv[1]).parent / "deck.yaml").exists() else "hand")
PY
  elif [[ -f "$PROJ/deck.yaml" ]]; then
    echo compose
  else
    echo hand
  fi
}

deck_root() {
  # hand mode may set root_dir in project.yaml; else project dir
  if [[ -f "$PROJ/project.yaml" ]]; then
    rd=$("$PY" - "$PROJ/project.yaml" <<'PY'
import sys
from pathlib import Path
text = Path(sys.argv[1]).read_text()
for line in text.splitlines():
    if line.strip().startswith("root_dir:"):
        print(line.split(":",1)[1].strip().strip('"').strip("'"))
        break
PY
)
    if [[ -n "${rd:-}" ]]; then
      if [[ "$rd" = /* ]]; then echo "$rd"; else echo "$PROJ/$rd"; fi
      return
    fi
  fi
  MODE="$(mode_from_yaml)"
  if [[ "$MODE" == "compose" && -f "$PROJ/dist/index.html" ]]; then
    echo "$PROJ/dist"
  else
    echo "$PROJ"
  fi
}

case "$CMD" in
  new)
    exec "$ROOT/scripts/new_project.sh" "$SLUG" "$@"
    ;;
  build)
    exec "$PY" "$ROOT/scripts/build_deck.py" --project "$PROJ" --engine "$ROOT"
    ;;
  serve)
    MODE="$(mode_from_yaml)"
    if [[ "$MODE" == "compose" ]]; then
      "$PY" "$ROOT/scripts/build_deck.py" --project "$PROJ" --engine "$ROOT"
    fi
    DIR="$(deck_root)"
    PORT="${1:-8080}"
    echo "Serving $DIR on http://127.0.0.1:${PORT}/"
    cd "$DIR" && exec "$PY" -m http.server "$PORT"
    ;;
  pdf)
    MODE="$(mode_from_yaml)"
    if [[ "$MODE" == "compose" ]]; then
      "$PY" "$ROOT/scripts/build_deck.py" --project "$PROJ" --engine "$ROOT"
    fi
    DIR="$(deck_root)"
    HTML="${1:-index.html}"
    OUT="${2:-deck.pdf}"
    # Prefer standalone if present
    if [[ -f "$DIR/index-standalone.html" && "$HTML" == "index.html" ]]; then
      HTML=index-standalone.html
    fi
    exec "$PY" "$ROOT/scripts/export_pdf.py" --dir "$DIR" --html "$HTML" --out "$OUT"
    ;;
  bundle)
    MODE="$(mode_from_yaml)"
    if [[ "$MODE" == "compose" ]]; then
      "$PY" "$ROOT/scripts/build_deck.py" --project "$PROJ" --engine "$ROOT"
    fi
    DIR="$(deck_root)"
    exec "$PY" "$ROOT/scripts/bundle_standalone.py" --dir "$DIR"
    ;;
  shell)
    echo "CALLIOPE_PROJECT_DIR=$PROJ"
    echo "CALLIOPE_ENGINE_ROOT=$ROOT"
    echo "mode=$(mode_from_yaml)"
    echo "deck_root=$(deck_root)"
    ;;
  *)
    echo "Unknown command: $CMD (build|serve|pdf|bundle|shell|new)" >&2
    exit 1
    ;;
esac
