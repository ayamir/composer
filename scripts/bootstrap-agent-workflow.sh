#!/usr/bin/env bash
set -euo pipefail

REPO_SLUG=${AGENT_WORKFLOW_REPO:-ayamir/composer}
REF=${AGENT_WORKFLOW_REF:-main}
TARGET_DIR=${1:-$(pwd)}
RAW_BASE="https://raw.githubusercontent.com/${REPO_SLUG}/${REF}"

mkdir -p "$TARGET_DIR"
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required" >&2
  exit 1
fi

fetch_to() {
  local relative_path=$1
  local destination=$2
  mkdir -p "$(dirname "$destination")"
  curl -fsSL "${RAW_BASE}/${relative_path}" -o "$destination"
}

append_line_once() {
  local file_path=$1
  local line=$2
  mkdir -p "$(dirname "$file_path")"
  touch "$file_path"
  if ! grep -qxF "$line" "$file_path"; then
    printf '\n%s\n' "$line" >> "$file_path"
  fi
}

ensure_makefile_include() {
  local makefile_path=$1
  if [[ ! -f "$makefile_path" ]]; then
    printf 'include Makefile.agent\n' > "$makefile_path"
    return 0
  fi

  if ! grep -qxF 'include Makefile.agent' "$makefile_path"; then
    printf '\ninclude Makefile.agent\n' >> "$makefile_path"
  fi
}

echo "Bootstrapping agent workflow into: $TARGET_DIR"
echo "Source: ${REPO_SLUG}@${REF}"

fetch_to "AGENTS.md" "$TARGET_DIR/AGENTS.md"
fetch_to "CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
fetch_to "Makefile.agent" "$TARGET_DIR/Makefile.agent"
fetch_to "README.agent-workflow.md" "$TARGET_DIR/README.agent-workflow.md"
fetch_to ".gitignore.agent-snippet" "$TARGET_DIR/.gitignore.agent-snippet"

fetch_to ".claude/settings.example.json" "$TARGET_DIR/.claude/settings.example.json"

fetch_to ".githooks/pre-commit" "$TARGET_DIR/.githooks/pre-commit"
fetch_to ".githooks/pre-push" "$TARGET_DIR/.githooks/pre-push"

fetch_to ".agent/.gitignore" "$TARGET_DIR/.agent/.gitignore"
fetch_to ".agent/task.md" "$TARGET_DIR/.agent/task.md"
fetch_to ".agent/plan.md" "$TARGET_DIR/.agent/plan.md"
fetch_to ".agent/state.md" "$TARGET_DIR/.agent/state.md"
fetch_to ".agent/test-matrix.md" "$TARGET_DIR/.agent/test-matrix.md"
fetch_to ".agent/implementation-report.md" "$TARGET_DIR/.agent/implementation-report.md"
fetch_to ".agent/review.md" "$TARGET_DIR/.agent/review.md"
fetch_to ".agent/verification-report.md" "$TARGET_DIR/.agent/verification-report.md"
fetch_to ".agent/decisions.md" "$TARGET_DIR/.agent/decisions.md"
fetch_to ".agent/knowledge-candidates.md" "$TARGET_DIR/.agent/knowledge-candidates.md"
fetch_to ".agent/scripts/capture-knowledge-prompt.sh" "$TARGET_DIR/.agent/scripts/capture-knowledge-prompt.sh"
fetch_to ".agent/scripts/check-workflow-readiness.sh" "$TARGET_DIR/.agent/scripts/check-workflow-readiness.sh"
fetch_to ".agent/scripts/context-summary.sh" "$TARGET_DIR/.agent/scripts/context-summary.sh"
fetch_to ".agent/scripts/install-agent-workflow.sh" "$TARGET_DIR/.agent/scripts/install-agent-workflow.sh"
fetch_to ".agent/scripts/review-with-codex.sh" "$TARGET_DIR/.agent/scripts/review-with-codex.sh"
fetch_to ".agent/scripts/validate-verification-report.sh" "$TARGET_DIR/.agent/scripts/validate-verification-report.sh"
fetch_to ".agent/scripts/verify-agent-state.sh" "$TARGET_DIR/.agent/scripts/verify-agent-state.sh"

fetch_to "docs/architecture.md" "$TARGET_DIR/docs/architecture.md"
fetch_to "docs/domain-glossary.md" "$TARGET_DIR/docs/domain-glossary.md"
fetch_to "docs/testing-guide.md" "$TARGET_DIR/docs/testing-guide.md"
mkdir -p "$TARGET_DIR/.agent/test-evidence"
touch "$TARGET_DIR/.agent/test-evidence/.gitkeep"

ensure_makefile_include "$TARGET_DIR/Makefile"
append_line_once "$TARGET_DIR/.gitignore" '# Optional agent workflow ignores'
while IFS= read -r ignore_line; do
  [[ -z "$ignore_line" ]] && continue
  append_line_once "$TARGET_DIR/.gitignore" "$ignore_line"
done < <(curl -fsSL "${RAW_BASE}/.gitignore.agent-snippet")

chmod +x "$TARGET_DIR/.agent/scripts/"*.sh
chmod +x "$TARGET_DIR/.githooks/"*

if git -C "$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  (cd "$TARGET_DIR" && bash .agent/scripts/install-agent-workflow.sh)
else
  echo "Skipping local hook installation because $TARGET_DIR is not a git repository yet."
  echo "After running git init, execute: make agent-setup"
fi

cat <<EOF

Agent workflow bootstrap complete.

Installed into: $TARGET_DIR

Next steps:
1. Customize docs/testing-guide.md with real test commands.
2. Customize AGENTS.md / docs/architecture.md / docs/domain-glossary.md for the target repository.
3. Start a task with: make agent-init-task

You can run this script from another repo with:
curl -fsSL ${RAW_BASE}/scripts/bootstrap-agent-workflow.sh | bash

Or target a different directory with:
curl -fsSL ${RAW_BASE}/scripts/bootstrap-agent-workflow.sh | bash -s -- /path/to/repo
EOF
