#!/usr/bin/env bash
set -euo pipefail

cat <<'PROMPT'
Please execute the Knowledge Capture Protocol.

Review:
1. The current conversation
2. git diff
3. .agent/task.md
4. .agent/state.md
5. .agent/plan.md
6. .agent/implementation-report.md
7. .agent/review.md
8. .agent/verification-report.md

Extract reusable knowledge that should persist beyond this task.

Classify each item as one of:
- project rule
- domain knowledge
- architecture knowledge
- testing knowledge
- tooling/workflow knowledge
- task-local note

Use this destination guide:
- README.md: human-facing project overview, setup, and common workflows
- AGENTS.md: rules all coding agents must follow
- CLAUDE.md: Claude Code-specific behavior, hooks, and preferences
- docs/domain-glossary.md: business terms, domain rules, state machines
- docs/architecture.md: modules, boundaries, data flow, system design
- docs/testing-guide.md: test commands, test data, verification methods
- .agent/task.md: current task goal and acceptance criteria
- .agent/state.md: current progress and temporary task state

Write candidates to:
.agent/knowledge-candidates.md

Do not directly update README.md, AGENTS.md, CLAUDE.md, or docs/* unless explicitly approved by the user.

For each candidate, include:
1. extracted knowledge
2. type
3. source
4. confidence
5. suggested destination file
6. reason it should persist
7. risk if wrong or outdated
8. whether human confirmation is needed
PROMPT
