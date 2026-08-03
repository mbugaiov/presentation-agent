#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export PYTHONPATH="$ROOT${PYTHONPATH:+:$PYTHONPATH}"
PASS=0
FAIL=0
for f in tests/fixtures/review-gate/*.md; do
  base=$(basename "$f")
  [[ "$base" == "SELF-REVIEW-TEMPLATE.md" ]] && continue
  expected=$(python3 -c "from scripts.review_gate import REVIEW_GATE_FIXTURES; print(REVIEW_GATE_FIXTURES.get('$base',''))")
  if [[ -z "$expected" ]]; then
    echo "unknown fixture: $base"
    FAIL=$((FAIL+1))
    continue
  fi
  if bash scripts/check_review_gate.sh "$f" >/dev/null 2>&1; then
    result=pass
  else
    result=fail
  fi
  if [[ "$result" == "$expected" ]]; then
    PASS=$((PASS+1))
  else
    echo "fixture mismatch: $base expected=$expected got=$result"
    FAIL=$((FAIL+1))
  fi
done
echo "review-gate fixtures: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
