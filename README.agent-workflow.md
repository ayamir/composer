# Agent Workflow Template

This template adds a practical multi-agent development workflow to a repository.

It is designed for local coding agents such as Claude Code, Codex, Aider, OpenCode, Gemini CLI, or similar tools.

## What It Gives You

- Shared rules for all agents: `AGENTS.md`
- Claude-specific instructions: `CLAUDE.md`
- Current task tracking: `.agent/task.md`
- Progress tracking: `.agent/state.md`
- Test design: `.agent/test-matrix.md`
- Verification evidence: `.agent/verification-report.md`
- Review handoff: `.agent/review.md`
- Makefile commands for daily use

## Recommended Daily Flow

```bash
make agent-setup

make agent-init-task
# edit .agent/task.md

# ask Claude Code to plan and implement
# then run:
make agent-review

# ask implementation agent to fix blocking review issues
make agent-verify
```

## Enforced Local Workflow

This repository can enforce the `.agent` workflow locally instead of relying on documentation alone.

Run once per clone:

```bash
make agent-setup
```

To install this workflow into a different repository via curl:

```bash
curl -fsSL https://raw.githubusercontent.com/ayamir/composer/main/scripts/bootstrap-agent-workflow.sh | bash
```

Or install into an explicit target directory:

```bash
curl -fsSL https://raw.githubusercontent.com/ayamir/composer/main/scripts/bootstrap-agent-workflow.sh | bash -s -- /path/to/repo
```

The bootstrap script installs the workflow skeleton and local hooks, but the target repository will still fail `agent-check` until you fill in `.agent/task.md`, `.agent/plan.md`, `.agent/state.md`, and `.agent/test-matrix.md` with real task content.

That setup installs two enforcement layers:

- Claude hooks in `.claude/settings.local.json`
- Git hooks via `core.hooksPath=.githooks`

### What runs in Claude hooks

- `SessionStart`: print `.agent/task.md`, `.agent/state.md`, recent decisions, and git status via `.agent/scripts/context-summary.sh`
- `PostCompact`: reload the same context summary after compaction
- `UserPromptSubmit`: run `.agent/scripts/check-workflow-readiness.sh readiness`
- `Stop`: run `.agent/scripts/check-workflow-readiness.sh stop`

Use Claude hooks for checks that should block starting or ending work in the chat loop.

### What runs in git hooks

- `pre-commit`: run `.agent/scripts/check-workflow-readiness.sh pre-commit`
- `pre-push`: run `.agent/scripts/check-workflow-readiness.sh pre-push`

Use git hooks for checks that should protect the repository even if the agent ignored or bypassed chat-level guidance.

### What is intentionally not in hooks

- Project test suites are not auto-run from hooks because they may be expensive or flaky.
- Review generation is not auto-run from hooks because it is a deliberate handoff step.
- CI enforcement is not included in this local-only template.

Instead, hooks enforce the lightweight prerequisites:

- task, plan, and test matrix must be filled in before code changes
- verification and review artifacts must be updated before push/stop when code changed

## Core Idea

Agents should not share private memory.

They should share durable artifacts:

- task brief
- plan
- implementation report
- test matrix
- verification report
- review report
- git diff

This makes the workflow auditable and keeps humans in control.
