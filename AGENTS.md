# AGENTS.md

This file defines the shared working agreement for all coding agents in this repository, including Codex, Claude Code, Aider, OpenCode, Gemini CLI, and other agentic coding tools.

The purpose of this file is to keep agent behavior predictable, auditable, and easy for humans to review.

---

## 1. Core Principle

Agents should not rely on private chat history as the source of truth.

The source of truth is:

1. Repository files
2. `.agent/task.md`
3. `.agent/state.md`
4. `.agent/decisions.md`
5. Tests and verification evidence
6. Git diff

When in doubt, read the task and state files again before editing.

---

## 2. Required Reading Before Any Task

Before making code changes, read these files:

1. `.agent/task.md`
2. `.agent/state.md`
3. `docs/architecture.md` if the task touches architecture, cross-service behavior, or shared abstractions
4. `docs/domain-glossary.md` if the task touches business logic, domain terms, workflows, permissions, state machines, or external integrations
5. `docs/testing-guide.md` if tests need to be added or updated

If a required file is missing or empty, create or update it before starting meaningful implementation.

---

## 3. Task Execution Protocol

For every non-trivial task:

1. Restate the goal in one concise sentence.
2. Identify non-goals and avoid expanding scope.
3. Update `.agent/plan.md` with the current plan.
4. Implement in small, reviewable steps.
5. After each meaningful step, update `.agent/state.md`.
6. Record important trade-offs in `.agent/decisions.md`.
7. Run relevant tests.
8. Write `.agent/verification-report.md`.
9. Do not mark the task done unless the acceptance criteria are satisfied.

---

## 4. Quality Control Protocol

For any behavior-changing task:

1. Prefer TDD.
2. First add or update tests that express the expected behavior.
3. Run the test and confirm it fails for the expected reason before implementation when practical.
4. Implement the smallest change that makes the test pass.
5. Every bug fix must include a regression test.
6. Every public API behavior change must include tests for:
   - success path
   - invalid input
   - boundary case
   - backward compatibility when applicable
7. Do not modify unrelated files.
8. Do not perform opportunistic refactoring unless explicitly requested.
9. After implementation, create or update `.agent/verification-report.md` with:
   - commands run
   - results
   - evidence
   - not verified items
   - known risks
10. A task is not complete unless:
   - acceptance criteria are satisfied
   - relevant tests passed
   - review findings are either fixed or documented

---

## 5. Implementation Rules

Follow these rules when editing code:

1. Prefer minimal changes.
2. Preserve existing public APIs unless `.agent/task.md` explicitly requires changing them.
3. Preserve backward compatibility unless explicitly told otherwise.
4. Do not introduce global mutable state unless justified in `.agent/decisions.md`.
5. Do not silently swallow errors.
6. Do not reduce logging, tracing, metrics, or observability without explanation.
7. Do not weaken validation or authorization checks.
8. Do not skip tests because they are slow. If they are not run, record that in `.agent/verification-report.md`.
9. Do not claim something is verified unless a command was actually run or direct evidence was inspected.
10. Prefer simple, explicit code over clever abstractions.

---

## 6. Test Matrix Requirement

Before changing behavior, update `.agent/test-matrix.md`.

The test matrix should include:

| Case | Input / Setup | Expected Result | Test Type | Status |
|---|---|---|---|---|

Use these categories where relevant:

- success path
- invalid input
- boundary case
- permission/authentication failure
- timeout/retry failure
- idempotency
- concurrency/race
- backward compatibility
- serialization/deserialization
- database state
- external service failure

---

## 7. Verification Report Requirement

After implementation, update `.agent/verification-report.md`.

The report must include:

1. Summary
2. Commands run
3. Results
4. Evidence
5. Not verified
6. Known risks
7. Follow-up recommendations

Important:

- If a command was not run, say so.
- If a test is flaky, say so.
- If verification depends on mocks, say so.
- If integration with a real dependency was not verified, say so.

---

## 8. Multi-Agent Collaboration Protocol

Agents collaborate through artifacts, not private memory.

The standard artifacts are:

- `.agent/task.md`: task goal and acceptance criteria
- `.agent/plan.md`: current implementation plan
- `.agent/state.md`: current progress and status
- `.agent/decisions.md`: important decisions and trade-offs
- `.agent/test-matrix.md`: test design
- `.agent/implementation-report.md`: implementation summary
- `.agent/review.md`: review findings
- `.agent/verification-report.md`: verification evidence

Recommended roles:

- Primary implementation agent: writes plan, tests, code, implementation report
- Review agent: reviews diff, tests, and reports; writes `.agent/review.md`; does not directly edit code unless explicitly asked
- Human: approves trade-offs, checks risk areas, decides merge readiness

---

## 9. Review Agent Rules

When acting as a review agent:

1. Read `.agent/task.md`.
2. Read `.agent/state.md`.
3. Read `.agent/test-matrix.md`.
4. Inspect `git diff`.
5. Review whether the implementation satisfies the acceptance criteria.
6. Review whether tests prove the behavior.
7. Do not edit code unless explicitly asked.
8. Write findings to `.agent/review.md`.

Review output must use this structure:

```md
# Review Report

## Summary

## Blocking Issues

## Non-blocking Suggestions

## Missing Tests

## Risk Assessment

## Questions for Human

## Final Recommendation
```

---

## 10. Context Recovery Protocol

When context becomes long, confusing, or deeply nested:

1. Stop editing.
2. Re-read `.agent/task.md`.
3. Re-read `.agent/state.md`.
4. Summarize:
   - original goal
   - current progress
   - remaining work
   - risks
5. Update `.agent/state.md`.
6. Continue only after the global view is restored.

Before compacting or summarizing a long session, update `.agent/state.md`.

---

## 11. Domain Knowledge Placement

Do not put all domain knowledge into this file.

Use:

- `README.md`: human-facing project overview
- `AGENTS.md`: shared agent instructions and workflow rules
- `CLAUDE.md`: Claude Code-specific behavior and hooks guidance
- `docs/architecture.md`: architecture and module relationships
- `docs/domain-glossary.md`: business/domain terms and rules
- `docs/testing-guide.md`: how to test this project
- `.agent/*.md`: current task state and agent collaboration artifacts

---

## 12. Completion Criteria

A task can be marked complete only when:

1. `.agent/task.md` acceptance criteria are satisfied.
2. Relevant tests have passed.
3. `.agent/verification-report.md` is updated.
4. `.agent/review.md` has no unresolved blocking issues, or unresolved issues are explicitly accepted by the human.
5. `git diff` contains no unrelated changes.
6. The final response includes:
   - files changed
   - tests run
   - known risks
   - not verified items

---

## Knowledge Capture Protocol

During a task, the user may provide important information in conversation that is not yet documented in the repository.

Agents must not assume this information will be available in future sessions unless it is written into repository files.

Before finishing a task, review the conversation, code changes, test results, and review findings. Extract reusable knowledge into `.agent/knowledge-candidates.md`.

Classify each candidate as one of:

- project rule
- domain knowledge
- architecture knowledge
- testing knowledge
- tooling/workflow knowledge
- task-local note

Use this destination guide:

- `README.md`: human-facing project overview, setup, and common workflows
- `AGENTS.md`: rules all coding agents must follow
- `CLAUDE.md`: Claude Code-specific behavior, hooks, and preferences
- `docs/domain-glossary.md`: business terms, domain rules, state machines
- `docs/architecture.md`: modules, boundaries, data flow, system design
- `docs/testing-guide.md`: test commands, test data, verification methods
- `.agent/task.md`: current task goal and acceptance criteria
- `.agent/state.md`: current progress and temporary task state

Do not directly update long-term documentation from conversation-only information unless explicitly approved by the user.

When proposing documentation updates, include:

1. the extracted knowledge
2. the suggested destination file
3. the reason it should persist
4. whether human confirmation is needed

Recommended flow:

1. Conversation context
2. `.agent/knowledge-candidates.md`
3. Human approval
4. Long-term documentation update

---

## Test Report Reliability Protocol

Agents must produce human-readable and evidence-backed test reports.

A test report is not valid if it only says that tests passed.

For every verification report:

1. Include the exact command that was run.
2. Include the purpose of the command.
3. Include the result.
4. Include evidence paths under `.agent/test-evidence/`.
5. Compare expected result and actual result.
6. Explicitly list not-verified items.
7. Explicitly list skipped tests and reasons.
8. Do not claim verification for commands that were not run.
9. Do not summarize away failures.
10. Preserve raw outputs when possible.

For backend tests, acceptable evidence includes:

- command output
- request payload
- response payload
- HTTP status code
- database query and result
- log excerpt
- trace id
- metric snapshot
- generated file checksum
- diff output

If evidence is missing, mark the case as `inconclusive`, not `pass`.

The final conclusion must be one of:

- `verified`
- `partially verified`
- `not verified`

Never use vague conclusions such as:

- looks good
- should work
- seems fine
- probably fixed
- 测试通过
- 没有问题
- 应该可以
- 看起来没问题
