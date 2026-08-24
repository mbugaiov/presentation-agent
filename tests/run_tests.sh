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

echo "== 6. Themis central review-rules wiring =="
WF=.github/workflows/code-review.yml
[[ -f "$WF" ]] || WF=.github/workflows/pr.yml
grep -q build_review_prompt.sh "$WF" && ok "workflow cites build_review_prompt" || no "workflow missing build_review_prompt"
grep -q 'repository: mbugaiov/themis-agent' "$WF" && ok "workflow checkouts themis-agent" || no "workflow missing themis checkout"
grep -q 'REVIEW_BIN=cursor-agent' "$WF" && ok "review prefers cursor-agent" || no "review missing REVIEW_BIN default"
grep -q 'command -v cursor-agent.*REVIEW_BIN=agent' "$WF" && ok "review falls back to agent" || no "review missing agent fallback"
grep -q 'exit 127' "$WF" && ok "review hard-fails without CLI" || no "review missing exit 127 guard"
grep -q 'command -v agent.*command -v cursor-agent' "$WF" && ok "install skips when binary on PATH" || no "install missing PATH short-circuit"
python3 - <<'PY2' "$WF" && ok "review checkout floats (no ref)" || no "review checkout must float without ref"
import sys, re
from pathlib import Path
text = Path(sys.argv[1]).read_text()
m = re.search(r"name: review \(Themis\)(.*?)name: isolation \(Themis\)", text, re.S)
chunk = m.group(1) if m else ""
idx = chunk.find("repository: mbugaiov/themis-agent")
window = chunk[idx:idx+220] if idx >= 0 else ""
raise SystemExit(0 if idx >= 0 and not re.search(r"(?m)^\s*ref:\s*", window) else 1)
PY2
if [[ -f scripts/ensure_themis_agent.sh ]]; then
  PIN=$(grep -Eo '[0-9a-f]{40}' scripts/ensure_themis_agent.sh | head -1 || true)
  [[ -z "${PIN:-}" ]] || grep -q "$PIN" "$WF" && ok "isolation pin present in workflow" || no "workflow missing themis pin"
fi
THEMIS_TMP=$(mktemp -d)
git clone --depth 1 https://github.com/mbugaiov/themis-agent.git "$THEMIS_TMP/themis" >/dev/null 2>&1
PROMPT_OUT=$(bash "$THEMIS_TMP/themis/scripts/build_review_prompt.sh" \
  --pr 1 --base origin/main --label selftest \
  --local-rule .cursor/rules/code-review.mdc \
  --themis-root "$THEMIS_TMP/themis")
echo "$PROMPT_OUT" | grep -q 'review-rules/10-tests-must-have' \
  && ok "build_review_prompt inlines shared pack" \
  || no "build_review_prompt selftest failed"
rm -rf "$THEMIS_TMP"

echo "== done pass=$PASS fail=$FAIL =="
[[ "$FAIL" -eq 0 ]]

