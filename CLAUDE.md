# CLAUDE.md

This file contains Claude Code-specific instructions for this repository.

Shared agent rules live in `AGENTS.md`. Do not duplicate all of them here. This file only contains Claude-specific workflow preferences.

---

## 1. Default Claude Code Behavior

When starting a task:

1. Read `AGENTS.md`.
2. Read `.agent/task.md`.
3. Read `.agent/state.md`.
4. If the task is complex, enter planning mode before editing.
5. Do not make large code changes before writing a plan to `.agent/plan.md`.

When implementing:

1. Prefer TDD for behavior changes and bug fixes.
2. Keep changes small and reviewable.
3. Update `.agent/state.md` after meaningful progress.
4. Record important decisions in `.agent/decisions.md`.
5. Write or update `.agent/implementation-report.md` after implementation.

When finishing:

1. Run relevant tests.
2. Update `.agent/verification-report.md`.
3. Summarize changed files, test results, risks, and not-verified items.
4. If review is needed, ask the user to run `make agent-review` or run the configured review command if explicitly allowed.

---

## 2. Planning Rules

For non-trivial tasks, create or update `.agent/plan.md` before editing.

The plan should include:

- Goal
- Non-goals
- Files likely to change
- Test strategy
- Risk areas
- Step-by-step plan
- Rollback considerations

Do not over-plan simple tasks, but always preserve the global goal in `.agent/task.md`.

---

## 3. TDD Preference

For bug fixes and behavior changes:

1. Add a failing test first when practical.
2. Run the focused test and confirm it fails for the expected reason.
3. Implement the minimal fix.
4. Run the focused test again.
5. Run the broader relevant test suite.
6. Update `.agent/verification-report.md`.

If TDD is not practical, explain why in `.agent/decisions.md`.

---

## 4. Context Recovery

If the conversation becomes long or deeply nested:

1. Re-read `.agent/task.md`.
2. Re-read `.agent/state.md`.
3. Write a short status summary into `.agent/state.md`.
4. Continue from the global goal instead of local investigation details.

Before context compaction, make sure `.agent/state.md` is current.

---

## 5. Suggested Claude Code Hooks

These hooks are optional. Keep them conservative at first.

Potential hook usage:

- `PostToolUse`: run formatter on modified files
- `Stop`: remind user to run `make agent-review`
- `SessionStart`: show `.agent/task.md` and `.agent/state.md`
- `PostCompact`: reload `.agent/task.md` and `.agent/state.md`

Do not automatically run expensive review or test commands unless the user has explicitly opted in.

A safer first step is to use manual commands:

```bash
make agent-status
make agent-review
make agent-verify
```

---

## 6. Review Collaboration with Codex

Recommended workflow:

1. Claude writes plan, tests, implementation, and verification report.
2. User runs `make agent-review`, or Claude runs it only with explicit permission.
3. Codex writes `.agent/review.md`.
4. Claude reads `.agent/review.md` and fixes blocking issues.
5. User reviews the final evidence.

Claude should not assume Codex has seen the same chat context. All necessary review context must be in files.
