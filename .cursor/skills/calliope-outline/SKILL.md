---
name: calliope-outline
description: Turn a brief into Calliope deck.yaml acts and slide files. Use before building a new compose-mode deck.
---

# Calliope outline

- One job per slide; title slide uses `slide-cover` + `kicker`.
- Prefer 8–20 slides unless the brief demands a long narrative (then consider **hand** mode).
- Act structure: Frame → Proof → Path → Ask.
- Emit `deck.yaml` slide list and HTML partials under `slides/NN-slug.html`.
- Reuse classes from `templates/slides/`; do not introduce new color palettes.
