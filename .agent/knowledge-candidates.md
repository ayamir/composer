# Knowledge Candidates

This file stores reusable knowledge discovered during the current task or conversation.

Agents should write candidates here before updating long-term documentation.

---

## Candidate Items

### 1. Title

**Type:** project rule / domain knowledge / architecture / testing / tooling-workflow / task-local  
**Source:** user conversation / code reading / test result / production issue / review finding  
**Confidence:** high / medium / low  
**Suggested Destination:** README.md / AGENTS.md / CLAUDE.md / docs/domain-glossary.md / docs/architecture.md / docs/testing-guide.md / .agent/state.md

**Content:**

<!-- Write the reusable knowledge here. -->

**Why it should persist:**

<!-- Explain why future agents or humans need this. -->

**Risk if wrong or outdated:**

<!-- Explain what may go wrong if this is inaccurate. -->

**Needs Human Confirmation:** yes / no

---

### 2. Local workflow enforcement should use local Claude settings plus git hooks

**Type:** tooling-workflow  
**Source:** code reading / implementation / test result  
**Confidence:** high  
**Suggested Destination:** README.md / AGENTS.md / CLAUDE.md

**Content:**

For this repository's `.agent` workflow, the practical local enforcement split is:
- Claude hooks in `.claude/settings.local.json` for session-start, prompt-submit, and stop checks
- Git hooks in `.githooks/` for pre-commit and pre-push checks

Project-local Claude settings should be written to `.claude/settings.local.json` and excluded via `.git/info/exclude`, not committed to shared project settings by default.

**Why it should persist:**

Future agents will otherwise regress to documentation-only workflow guidance and may accidentally commit local hook state.

**Risk if wrong or outdated:**

If the preferred settings file changes in the toolchain, this guidance could point agents to the wrong integration path.

**Needs Human Confirmation:** yes

---

## Approved Updates

| Item | Destination | Status |
|---|---|---|
| | | pending |
