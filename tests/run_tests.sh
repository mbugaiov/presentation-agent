#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PASS=0
FAIL=0
ok() { echo "OK  $1"; PASS=$((PASS+1)); }
no() { echo "FAIL  $1"; FAIL=$((FAIL+1)); }

bash scripts/portability_check.sh && ok portability || no portability
bash scripts/projects_isolation_check.sh && ok projects_isolation || no projects_isolation

# build sample from examples
rm -rf examples/sample-pitch/dist
./scripts/calliope.sh sample-pitch build
test -f examples/sample-pitch/dist/index.html && ok sample_build || no sample_build
grep -q 'calliope.css' examples/sample-pitch/dist/index.html && ok theme_link || no theme_link
grep -q 'kicker' examples/sample-pitch/dist/index.html && ok kicker_class || no kicker_class
! grep -q '/Users/' examples/sample-pitch/dist/index.html && ok no_abs_users || no no_abs_users

OUT=$(./scripts/calliope.sh sample-pitch shell)
echo "$OUT" | grep -q CALLIOPE_PROJECT_DIR && ok shell || no shell

bash scripts/check_review_gate_fixtures.sh && ok review_gate_fixtures || no review_gate_fixtures

echo "== done pass=$PASS fail=$FAIL =="

# Themis central review-rules wiring — exercise builder
WF=.github/workflows/code-review.yml
[[ -f "$WF" ]] || WF=.github/workflows/pr.yml
grep -q build_review_prompt.sh "$WF"
grep -q 'repository: mbugaiov/themis-agent' "$WF"
if [[ -f scripts/ensure_themis_agent.sh ]]; then
  PIN=$(grep -Eo '[0-9a-f]{40}' scripts/ensure_themis_agent.sh | head -1 || true)
  [[ -z "${PIN:-}" ]] || grep -q "$PIN" .github/workflows/auto-merge.yml 2>/dev/null || grep -q "$PIN" "$WF"
fi
THEMIS_TMP=$(mktemp -d)
git clone --depth 1 https://github.com/mbugaiov/themis-agent.git "$THEMIS_TMP/themis" >/dev/null 2>&1
PROMPT_OUT=$(bash "$THEMIS_TMP/themis/scripts/build_review_prompt.sh" \
  --pr 1 --base origin/main --label selftest \
  --local-rule .cursor/rules/code-review.mdc \
  --themis-root "$THEMIS_TMP/themis")
echo "$PROMPT_OUT" | grep -q 'review-rules/10-tests-must-have'
rm -rf "$THEMIS_TMP"

[[ "$FAIL" -eq 0 ]]

