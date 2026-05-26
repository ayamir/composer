#!/usr/bin/env bash
set -euo pipefail

missing=0

required_files=(
  "AGENTS.md"
  ".agent/task.md"
  ".agent/state.md"
  ".agent/plan.md"
  ".agent/test-matrix.md"
  ".agent/verification-report.md"
)

for f in "${required_files[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "Missing required file: $f"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo "Agent workflow files are present."
echo

echo "Git status:"
git status --short || true
echo

echo "Current task status:"
grep -n "Status:" .agent/state.md || true
