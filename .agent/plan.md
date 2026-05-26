# Implementation Plan

Agents should update this file before making non-trivial changes.

---

## Goal

Add lightweight, enforceable local workflow automation for the current `.agent`-based process.

---

## Non-goals

- Replace the repository workflow with OpenSpec.
- Add CI integration or project-specific test execution.
- Make hooks depend on external tools beyond shell and Python 3.

---

## Files Likely to Change

| File | Expected Change |
|---|---|
| .agent/scripts/check-workflow-readiness.sh | New shared validator for edit, commit, and stop gates. |
| .agent/scripts/install-agent-workflow.sh | New one-command installer for Claude and git hooks. |
| .claude/settings.example.json | Update example to include enforcing hooks. |
| Makefile.agent | Add a setup target. |
| README.agent-workflow.md | Explain enforced workflow and hook responsibilities. |

---

## Test Strategy

- Unit tests: not applicable; validate shell scripts with direct invocation.
- Integration tests: run installer, inspect generated files, and execute hook scripts directly.
- Regression tests: verify existing report validator still works and hooks stay idempotent.
- Manual verification: run setup twice, inspect merged Claude settings, and execute git hooks.

---

## Risk Areas

- Hook scope selection: enforce only high-signal checks in hooks to avoid blocking normal exploration.
- Settings merge logic: preserve unrelated JSON settings while inserting required hooks.

---

## Plan

- [ ] Step 1: Define which workflow checks belong in Claude hooks versus git hooks.
- [ ] Step 2: Implement reusable validation and installation scripts, then wire them into Makefile and Claude settings.
- [ ] Step 3: Document usage and verify installation plus validation flows.

---

## Rollback Plan

<!-- How can this change be reverted or disabled? -->

Remove `.githooks/`, restore previous `.claude/settings.local.json` from the backup produced by the installer, and delete the new setup scripts.

---

## Notes
