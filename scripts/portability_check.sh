#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
FORBIDDEN='(\blrm\b|sol-ark|solark|qa_lab_resource_management|/Users/max/Downloads|920b59c1|1258487975|712020:ec4910fd|RQ-1579|Fidelity|Sombrainc)'
PATHS=(.cursor templates tests AGENTS.md PORTABILITY.md SETUP.md README.md docs scripts theme)
# theme/calliope.css is large product-agnostic — still scan for leaks
FAIL=0
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  [[ "$f" == "scripts/portability_check.sh" ]] && continue
  [[ "$f" == examples/* ]] && continue
  [[ "$f" == theme/calliope.css ]] && continue  # visual system only; huge
  while IFS= read -r line; do
    echo "$line" | grep -q 'e\.g\. `<slug>`' && continue
    echo "$line" | grep -q 'e\.g\. <slug>' && continue
    echo "$line" | grep -q 'examples/' && continue
    echo "portability leak: $line"
    FAIL=1
  done < <(git grep -nE "$FORBIDDEN" -- "$f" 2>/dev/null || true)
done < <(git ls-files "${PATHS[@]}" 2>/dev/null || true)
if [[ "$FAIL" -eq 0 ]]; then
  echo "portability: OK"
fi
exit "$FAIL"
