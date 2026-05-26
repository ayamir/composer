#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
MODE=${1:-readiness}

cd "$ROOT_DIR"

failures=()

record_failure() {
  failures+=("$1")
}

print_failures_and_exit() {
  local prefix=$1
  if [[ ${#failures[@]} -eq 0 ]]; then
    return 0
  fi

  {
    echo "$prefix"
    for item in "${failures[@]}"; do
      echo "- $item"
    done
  } >&2
  exit 1
}

trimmed_nonempty_line_exists() {
  local file_path=$1
  local start_pattern=$2
  local end_pattern=$3

  python3 - "$file_path" "$start_pattern" "$end_pattern" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
start_pattern = re.compile(sys.argv[2])
end_pattern = re.compile(sys.argv[3])

text = path.read_text(encoding="utf-8")
inside = False
for line in text.splitlines():
    if not inside and start_pattern.search(line):
        inside = True
        continue
    if inside and end_pattern.search(line):
        break
    if inside:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("<!--"):
            continue
        if stripped in {"-", "- [ ]", "| | |", "|---|---|", "```"}:
            continue
        if set(stripped) <= {"|", "-", ":", " "}:
            continue
        if stripped.startswith("| ") and stripped.endswith(" |"):
            cells = [cell.strip() for cell in stripped.strip("|").split("|")]
            if all(not cell for cell in cells):
                continue
            if cells == ["", ""]:
                continue
            if all(set(cell) <= {"-", ":"} for cell in cells if cell):
                continue
        sys.exit(0)

sys.exit(1)
PY
}

section_has_content() {
  local file_path=$1
  local section_title=$2
  trimmed_nonempty_line_exists "$file_path" "^${section_title}$" '^---$'
}

file_contains() {
  local file_path=$1
  local pattern=$2
  grep -Eq "$pattern" "$file_path"
}

CODE_CHANGE_PATTERN='^(src/|lib/|app/|cmd/|pkg/|internal/|crates/|tests?/|examples/|benches/|Cargo\.(toml|lock)|go\.(mod|sum)|package(-lock)?\.json|pnpm-lock\.yaml|yarn\.lock|pyproject\.toml|requirements[^/]*\.txt|setup\.py|Makefile$)'
WORKFLOW_CHANGE_PATTERN='^(\.agent/scripts/|\.githooks/|Makefile\.agent$|\.claude/settings(\.example)?\.json$|README\.agent-workflow\.md$|AGENTS\.md$|CLAUDE\.md$)'

has_staged_matching_changes() {
  local pattern=$1
  git diff --cached --name-only --diff-filter=ACMR | grep -Eq "$pattern"
}

has_repo_matching_changes() {
  local pattern=$1
  {
    git diff --name-only HEAD
    git ls-files --others --exclude-standard
  } | sort -u | grep -Eq "$pattern"
}

ensure_required_files_exist() {
  local required=(
    "AGENTS.md"
    ".agent/task.md"
    ".agent/state.md"
    ".agent/plan.md"
    ".agent/test-matrix.md"
    ".agent/verification-report.md"
    ".agent/review.md"
  )

  local file
  for file in "${required[@]}"; do
    if [[ ! -f "$file" ]]; then
      record_failure "Missing required workflow file: $file"
    fi
  done
}

check_task_and_plan_content() {
  if ! section_has_content ".agent/task.md" '## 1\. Goal'; then
    record_failure "Fill in .agent/task.md -> Goal before making code changes."
  fi

  if ! section_has_content ".agent/task.md" '## 3\. Background'; then
    record_failure "Add concrete background to .agent/task.md before making code changes."
  fi

  if ! section_has_content ".agent/task.md" '## 4\. Acceptance Criteria'; then
    record_failure "List concrete acceptance criteria in .agent/task.md before making code changes."
  fi

  if ! section_has_content ".agent/plan.md" '## Goal'; then
    record_failure "Fill in .agent/plan.md -> Goal before making non-trivial changes."
  fi

  if ! section_has_content ".agent/plan.md" '## Plan'; then
    record_failure "Add actionable implementation steps to .agent/plan.md before making code changes."
  fi
}

check_test_design_content() {
  if ! trimmed_nonempty_line_exists ".agent/test-matrix.md" '^\| Case \| Input / Setup \| Expected Result \| Test Type \| Status \|$' '^---$'; then
    record_failure "Update .agent/test-matrix.md with concrete test cases before behavior-changing work."
  fi
}

check_verification_artifacts() {
  if ! file_contains ".agent/verification-report.md" 'Status: verified|Status: partially verified|Status: not verified'; then
    record_failure "Verification summary in .agent/verification-report.md must declare explicit status."
  fi

  if ! file_contains ".agent/verification-report.md" '\| [^|]+ \| [^|]+ \| (pass|fail|skipped) \|'; then
    record_failure "Record at least one verification command with result in .agent/verification-report.md."
  fi

  if grep -Eiq '\bpass\b' .agent/verification-report.md && ! grep -Eq '\.agent/test-evidence/' .agent/verification-report.md; then
    record_failure "Verification report mentions a passing result but does not reference .agent/test-evidence/."
  fi
}

check_review_file() {
  if file_contains ".agent/review.md" '^Recommendation: request changes$'; then
    record_failure "Update .agent/review.md with the actual review outcome before considering the task complete."
  fi
}

check_state_summary() {
  if ! section_has_content ".agent/state.md" '## Original Goal'; then
    record_failure "Restate the current goal in .agent/state.md."
  fi
}

case "$MODE" in
  readiness)
    ensure_required_files_exist
    check_task_and_plan_content
    check_state_summary
    check_test_design_content
    print_failures_and_exit "Workflow readiness check failed:"
    ;;
  pre-commit)
    ensure_required_files_exist
    if has_staged_matching_changes "$CODE_CHANGE_PATTERN|$WORKFLOW_CHANGE_PATTERN"; then
      check_task_and_plan_content
      check_state_summary
      check_test_design_content
    fi
    print_failures_and_exit "Pre-commit workflow check failed:"
    ;;
  pre-push|stop)
    ensure_required_files_exist
    if has_repo_matching_changes "$CODE_CHANGE_PATTERN|$WORKFLOW_CHANGE_PATTERN"; then
      check_task_and_plan_content
      check_state_summary
      check_test_design_content
      check_verification_artifacts
      check_review_file
    fi
    print_failures_and_exit "Workflow completion check failed:"
    ;;
  *)
    echo "Unknown mode: $MODE" >&2
    echo "Usage: $0 [readiness|pre-commit|pre-push|stop]" >&2
    exit 2
    ;;
esac
