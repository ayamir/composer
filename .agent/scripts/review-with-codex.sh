#!/usr/bin/env bash
set -euo pipefail

mkdir -p .agent

REVIEW_INPUT=".agent/review-input.md"
REVIEW_OUTPUT=".agent/review.md"

cat > "$REVIEW_INPUT" <<'EOF'
# Review Input

You are the review agent.

Review the current repository changes using:
- .agent/task.md
- .agent/state.md
- .agent/plan.md
- .agent/test-matrix.md
- .agent/implementation-report.md
- .agent/verification-report.md
- git diff

Do not edit code.

Write the review result to .agent/review.md using this structure:

# Review Report

## Summary

## Blocking Issues

## Non-blocking Suggestions

## Missing Tests

## Risk Assessment

## Questions for Human

## Final Recommendation

Review checklist:

1. Does the implementation satisfy .agent/task.md acceptance criteria?
2. Are there unrelated changes?
3. Are tests sufficient to prove the behavior?
4. Are edge cases covered?
5. Are backward compatibility risks handled?
6. Are errors handled explicitly?
7. Are concurrency, retry, idempotency, and timeout risks considered where relevant?
8. Are logs, metrics, or traces preserved or improved?
9. Is the implementation minimal enough?
10. Are not-verified items clearly documented?
EOF

{
  echo
  echo "# Current Git Status"
  echo
  git status --short || true
  echo
  echo "# Current Git Diff Stat"
  echo
  git diff --stat || true
  echo
  echo "# Current Git Diff"
  echo
  git diff || true
} >> "$REVIEW_INPUT"

if command -v codex >/dev/null 2>&1; then
  codex exec "Review the repository changes according to .agent/review-input.md. Write the final review to .agent/review.md. Do not edit code."
else
  echo "codex command not found." >&2
  echo "Review input has been written to $REVIEW_INPUT." >&2
  echo "You can paste it into your review agent manually." >&2
  exit 127
fi

echo "Review written to $REVIEW_OUTPUT"
