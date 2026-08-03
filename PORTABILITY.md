# Portability — presentation-agent

Same contract as sibling engines:

- No live product URLs / customer names / absolute home paths in tracked engine
  docs/skills/rules (except `examples/<slug>/`)
- Live `projects/<slug>/` gitignored except `_template/`
- Theme CSS may be large but must stay **product-agnostic** (no customer strings)

```bash
bash scripts/portability_check.sh
bash scripts/projects_isolation_check.sh
```
