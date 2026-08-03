---
name: calliope-build
description: Build, serve, PDF, or bundle a Calliope project deck.
---

# Calliope build

```bash
./scripts/calliope.sh <slug> build    # compose → dist/
./scripts/calliope.sh <slug> serve    # http://127.0.0.1:8080
./scripts/calliope.sh <slug> pdf      # needs Playwright
./scripts/calliope.sh <slug> bundle   # index-standalone.html
./scripts/calliope.sh <slug> shell
```

Compose output must link `calliope.css` + `boot.js`. Fail if absolute `/Users/` paths appear in HTML.
