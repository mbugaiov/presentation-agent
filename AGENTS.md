# Calliope — Presentation engine (`presentation-agent`)

**Calliope** builds and ships **reveal.js decks** in the house visual system
(dark navy, accent blue, kickers / cards / chips / Mermaid / PDF).

> **Naming:** Calliope (brand) ≡ `presentation-agent` repo ≡ factory `agent=presentation`.
> Pantheon siblings: Hermes, Hephaestus, Athena, Argus, Themis, Chronos, Metis.
> Presentation: *Calliope · Decks*.

> **Not on every impl-dev tick.** Engagement-driven: pitch decks, factory narratives,
> client readouts. Optional label `impl-deck` may kick a rebuild after metrics refresh.

## Capabilities

| Capability | Skill | CLI |
|------------|-------|-----|
| Full deck loop (brief → outline → build → PDF) | `calliope-loop` | `./scripts/calliope.sh <slug> …` |
| Outline / acts from a brief | `calliope-outline` | (agent) + `deck.yaml` |
| Assemble HTML in Calliope theme | `calliope-build` | `calliope.sh <slug> build` |
| Serve / PDF / standalone bundle | `calliope-build` | `serve` · `pdf` · `bundle` |
| Engine PR review | `calliope-code-review` | `code-review.yml` + Themis isolation + review gate |

## Modes

| Mode | When | Layout |
|------|------|--------|
| **compose** | New decks | `deck.yaml` + `slides/*.html` → `build` writes `dist/index.html` with `theme/calliope.css` |
| **hand** | Existing full decks (e.g. large narratives) | Project owns `index.html` (already themed); Calliope only `serve` / `pdf` / `bundle` |

## Layout

```
presentation-agent/
  AGENTS.md PORTABILITY.md SETUP.md README.md
  theme/calliope.css          canonical visual system (from house deck)
  theme/shell.html            compose shell ({{TITLE}} {{SLIDES}} …)
  theme/boot.js               Reveal + Mermaid boot
  templates/                  slide starters + deck.yaml.example
  examples/sample-pitch/      committed compose sample
  projects/_template/
  projects/<slug>/            live (gitignored) — compose or hand
  scripts/calliope.sh
  .cursor/skills/
```

## Hard rules

- New slides **must** use Calliope theme classes (`kicker`, `card`, `chip`, `stat`, …) — do not invent a parallel look.
- No customer URLs / board IDs in tracked engine docs (only `examples/` + live `projects/`).
- Never commit secrets or huge binary dumps into the engine repo; keep assets under the project.

See **`SETUP.md`**, **`PORTABILITY.md`**, **`docs/CAPABILITIES.md`**.
