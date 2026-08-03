# Setup — Calliope (`presentation-agent`)

## Prerequisites

- Python **3.12+**
- For PDF: `pip install playwright && python3 -m playwright install chromium`

## New project (compose)

```bash
./scripts/new_project.sh <slug> "Display Name"
# edit projects/<slug>/deck.yaml + slides/
./scripts/calliope.sh <slug> build
./scripts/calliope.sh <slug> serve
```

## Existing hand deck

```bash
./scripts/new_project.sh <slug> "Display Name" --mode hand
# point project.yaml root_dir at a folder that already has index.html
# or copy/symlink the deck into projects/<slug>/
./scripts/calliope.sh <slug> serve
./scripts/calliope.sh <slug> pdf
./scripts/calliope.sh <slug> bundle
```

## Isolation

Never commit `projects/<slug>/` live data. Engine PRs go through **review (Themis)** +
**isolation (Themis)** like sibling engines. Configure repo secret `CURSOR_API_KEY` for
automated Cursor review on PRs.
