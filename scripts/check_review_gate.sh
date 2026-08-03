#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FILE="${1:-review.md}"
python3 "$ROOT/scripts/review_gate.py" "$FILE"
