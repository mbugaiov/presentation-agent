#!/usr/bin/env bash
# Ensure live projects/ are gitignored (except _template).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
tracked=$(git ls-files 'projects/*' 2>/dev/null | grep -v '^projects/_template' || true)
if [[ -n "$tracked" ]]; then
  echo "projects isolation FAIL — tracked live paths:"
  echo "$tracked"
  exit 1
fi
echo "projects isolation: OK"
