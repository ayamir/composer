# Task Brief

This file is the source of truth for the current task.

Agents must read this file before making changes.

---

## 1. Goal

<!-- What should be achieved? Keep this concrete and verifiable. -->

Add enforceable local workflow hooks for the repository and provide a one-command setup script.

---

## 2. Non-goals

<!-- What should not be changed or expanded? -->

- Do not make unrelated refactors.
- Do not change public APIs unless explicitly required.
- Do not modify unrelated files.

---

## 3. Background

<!-- Add context, links, issue descriptions, error messages, or examples. -->

The repository currently defines the agent workflow mostly in documentation and template files.
Those rules are not enforced by active Claude hooks or git hooks, so the workflow can be skipped.
This task converts key workflow checks into executable local enforcement while keeping the setup lightweight and tool-agnostic.

---

## 4. Acceptance Criteria

<!-- The task is done only if these are satisfied. -->

- [ ] A one-command setup script installs local git hooks and enables project Claude hooks without clobbering unrelated settings.
- [ ] Hook checks enforce the most important workflow gates for editing and task completion using the existing `.agent` artifacts.
- [ ] Repository docs and task artifacts explain which checks run in Claude hooks vs git hooks and how to use the setup.

---

## 5. Constraints

<!-- Compatibility, performance, security, observability, migration, rollout constraints. -->

- Backward compatibility: Do not break existing manual Makefile workflows.
- Performance: Hook checks should stay lightweight and avoid running project test suites automatically.
- Security: Do not grant broader permissions or rely on network access.
- Observability: Hook failures should print explicit remediation steps.
- Migration: Reuse existing `.agent/scripts` where possible and avoid destructive changes to user settings.

---

## 6. Risk Areas

<!-- Examples: concurrency, retries, idempotency, auth, schema compatibility, cache invalidation. -->

- Existing users may already have `.claude/settings.local.json`; setup must merge instead of overwrite.
- Overly strict hooks may block harmless exploration or documentation-only edits.

---

## 7. Key Files

<!-- Files likely involved in this task. -->

| File | Why it matters |
|---|---|
| Makefile.agent | Add setup commands for the local workflow bootstrap. |
| .claude/settings.example.json | Source template for project Claude hook configuration. |
| .agent/scripts/* | Existing workflow scripts to reuse and extend for enforcement. |
| README.agent-workflow.md | Document the enforced setup and expected usage. |

---

## 8. Done Criteria

- [ ] Acceptance criteria are satisfied.
- [ ] Relevant tests are updated.
- [ ] Relevant tests pass.
- [ ] `.agent/test-matrix.md` is updated.
- [ ] `.agent/implementation-report.md` is updated.
- [ ] `.agent/verification-report.md` is updated.
- [ ] `.agent/review.md` has no unresolved blocking issues.
- [ ] No unrelated files are changed.
