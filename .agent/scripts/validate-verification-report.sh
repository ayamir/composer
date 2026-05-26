#!/usr/bin/env bash
set -euo pipefail

REPORT=".agent/verification-report.md"

if [[ ! -f "$REPORT" ]]; then
  echo "ERROR: $REPORT does not exist."
  exit 1
fi

required_sections=(
  "# Verification Report"
  "## 1. Summary"
  "## 2. Scope"
  "## 3. Environment"
  "## 4. Commands Run"
  "## 5. Test Cases"
  "## 6. Expected vs Actual Summary"
  "## 7. Evidence Index"
  "## 8. Failures and Anomalies"
  "## 9. Risks"
  "## 10. Final Conclusion"
)

for section in "${required_sections[@]}"; do
  if ! grep -qF "$section" "$REPORT"; then
    echo "ERROR: missing required section: $section"
    exit 1
  fi
done

forbidden_phrases=(
  "looks good"
  "seems fine"
  "should work"
  "probably fixed"
  "测试通过"
  "没有问题"
  "应该可以"
  "看起来没问题"
)

for phrase in "${forbidden_phrases[@]}"; do
  if grep -qi "$phrase" "$REPORT"; then
    echo "ERROR: vague or unsupported phrase found: $phrase"
    exit 1
  fi
done

if ! grep -Eq "Status: verified|Status: partially verified|Status: not verified" "$REPORT"; then
  echo "ERROR: Summary must include one of:"
  echo "  Status: verified"
  echo "  Status: partially verified"
  echo "  Status: not verified"
  exit 1
fi

if ! grep -Eq "verified|partially verified|not verified" "$REPORT"; then
  echo "ERROR: final conclusion must be explicit."
  exit 1
fi

if grep -Eq "pass|PASS|Pass" "$REPORT"; then
  if ! grep -q ".agent/test-evidence/" "$REPORT"; then
    echo "ERROR: report contains pass result but no .agent/test-evidence/ path."
    exit 1
  fi
fi

echo "Verification report structure looks valid."
