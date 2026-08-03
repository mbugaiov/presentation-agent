---
name: calliope-code-review
description: Engine PR review for presentation-agent — follow code-review.mdc, review gate, and Themis isolation.
---

# Calliope engine code review

Follow `.cursor/rules/code-review.mdc` and `calliope-engine.mdc`.

```bash
bash scripts/check_review_gate.sh review.md
bash scripts/check_review_gate_fixtures.sh
```

CI jobs on every PR to `main`:

| Job | Workflow |
|-----|----------|
| `test` | `ci.yml` |
| `review (Themis)` | `code-review.yml` — Cursor agent + blocking gate |
| `isolation (Themis)` | `code-review.yml` — `themis-agent` `ci_isolation.sh --mode engine` |

Auto-merge (`auto-merge.yml`) squash-merges when all three required checks are green.
