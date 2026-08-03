---
name: calliope-loop
description: Run the Calliope deck loop — brief → outline → compose/build → serve/PDF. Use when creating or refreshing a presentation in the house reveal.js format.
---

# Calliope loop

1. Read `AGENTS.md` + project `project.yaml` (mode `compose` vs `hand`).
2. Confirm brief / audience / ask (human or `brief.md` in project).
3. **compose:** outline → `deck.yaml` + `slides/*.html` using theme classes (`kicker`, `card`, `chip`, `stat`, `note`, `cols`, `grid2`/`grid3`).
4. `./scripts/calliope.sh <slug> build` then `serve` (or `pdf` / `bundle`).
5. **hand:** edit existing `index.html` in place; keep Calliope visual language; `serve`/`pdf`/`bundle` only.
6. Record evidence path (`dist/index.html` or PDF) in the requesting ticket/chat.

Never invent a second visual system. Theme source: `theme/calliope.css`.
