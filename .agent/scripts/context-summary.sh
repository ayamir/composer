#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "AGENT CONTEXT SUMMARY"
echo "============================================================"
echo

if [[ -f .agent/task.md ]]; then
  echo "---------------- .agent/task.md ----------------"
  sed -n '1,220p' .agent/task.md
  echo
fi

if [[ -f .agent/state.md ]]; then
  echo "---------------- .agent/state.md ----------------"
  sed -n '1,220p' .agent/state.md
  echo
fi

if [[ -f .agent/decisions.md ]]; then
  echo "---------------- recent decisions ----------------"
  tail -n 120 .agent/decisions.md
  echo
fi

echo "---------------- git status ----------------"
git status --short || true
echo

echo "---------------- git diff stat ----------------"
git diff --stat || true
echo
