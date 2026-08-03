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

echo "== done pass=$PASS fail=$FAIL =="
[[ "$FAIL" -eq 0 ]]
