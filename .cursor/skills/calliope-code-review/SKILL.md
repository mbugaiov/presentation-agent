---
name: calliope-code-review
description: Review presentation-agent engine PRs for theme portability and CLI safety.
---

# Calliope code review

- Portability gate green; no customer hardcodes in tracked engine files.
- Theme changes are intentional and documented; do not fork a second CSS system in examples.
- `calliope.sh` requires explicit `<slug>`; no silent product defaults.
- Live `projects/` remain gitignored except `_template/`.
