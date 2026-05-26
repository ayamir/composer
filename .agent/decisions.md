# Decisions Log

Record important decisions, trade-offs, and rejected alternatives.

---

| Time | Decision | Reason | Alternatives Considered |
|---|---|---|---|
| 2026-05-26 19:39 +0800 | Install Claude hooks into `.claude/settings.local.json` and git-ignore them via `.git/info/exclude` | Keep the one-command setup usable without polluting committed project files or overwriting shared settings. | Writing directly to `.claude/settings.json`; keeping hooks manual-only. |
| 2026-05-26 19:39 +0800 | Enforce lightweight artifact gates in hooks but do not auto-run test suites | Fast feedback and low friction are better suited to hooks; expensive or flaky checks belong in manual verification or future CI. | Running project test suites from hooks; only keeping documentation with no automated enforcement. |

---

## Decision Template

```md
## YYYY-MM-DD HH:mm - Decision Title

### Decision

### Reason

### Alternatives Considered

### Risk

### Follow-up
```
