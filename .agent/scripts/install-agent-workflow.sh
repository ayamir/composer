#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
CLAUDE_DIR="$ROOT_DIR/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"
BACKUP_FILE="$CLAUDE_DIR/settings.local.json.bak"
GIT_HOOKS_DIR="$ROOT_DIR/.githooks"
LOCAL_EXCLUDE_FILE=$(git -C "$ROOT_DIR" rev-parse --git-path info/exclude)

mkdir -p "$CLAUDE_DIR" "$GIT_HOOKS_DIR"

chmod +x "$ROOT_DIR/.agent/scripts/check-workflow-readiness.sh"
chmod +x "$ROOT_DIR/.agent/scripts/verify-agent-state.sh"
chmod +x "$ROOT_DIR/.agent/scripts/context-summary.sh"
chmod +x "$ROOT_DIR/.agent/scripts/validate-verification-report.sh"
chmod +x "$ROOT_DIR/.githooks/pre-commit"
chmod +x "$ROOT_DIR/.githooks/pre-push"

git -C "$ROOT_DIR" config core.hooksPath .githooks

mkdir -p "$(dirname "$LOCAL_EXCLUDE_FILE")"
touch "$LOCAL_EXCLUDE_FILE"
for pattern in ".claude/settings.local.json" ".claude/settings.local.json.bak"; do
  if ! grep -qxF "$pattern" "$LOCAL_EXCLUDE_FILE"; then
    echo "$pattern" >> "$LOCAL_EXCLUDE_FILE"
  fi
done

if [[ -f "$SETTINGS_FILE" && ! -f "$BACKUP_FILE" ]]; then
  cp "$SETTINGS_FILE" "$BACKUP_FILE"
fi

python3 - "$SETTINGS_FILE" <<'PY'
import json
import sys
from pathlib import Path

settings_path = Path(sys.argv[1])
if settings_path.exists():
    data = json.loads(settings_path.read_text(encoding="utf-8"))
else:
    data = {}

hooks = data.setdefault("hooks", {})

desired = {
    "SessionStart": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": "bash .agent/scripts/context-summary.sh"
                }
            ]
        }
    ],
    "PostCompact": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": "bash .agent/scripts/context-summary.sh"
                }
            ]
        }
    ],
    "UserPromptSubmit": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": "bash .agent/scripts/check-workflow-readiness.sh readiness"
                }
            ]
        }
    ],
    "Stop": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": "bash .agent/scripts/check-workflow-readiness.sh stop"
                }
            ]
        }
    ]
}

for event, entries in desired.items():
    current = hooks.setdefault(event, [])
    existing_commands = {
        hook.get("command")
        for group in current if isinstance(group, dict)
        for hook in group.get("hooks", []) if isinstance(hook, dict)
    }
    for entry in entries:
        commands = [hook.get("command") for hook in entry.get("hooks", []) if isinstance(hook, dict)]
        if not any(cmd in existing_commands for cmd in commands):
            current.append(entry)

settings_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY

cat <<EOF
Agent workflow setup complete.

Installed:
- git hooks via core.hooksPath=.githooks
- project Claude hooks in .claude/settings.local.json

Checks now run in these places:
- Claude SessionStart/PostCompact: context summary
- Claude UserPromptSubmit: workflow readiness validation
- Claude Stop: workflow completion validation
- git pre-commit: workflow readiness for staged code changes
- git pre-push: verification/review gates before push

Next steps:
1. Review .claude/settings.local.json and keep the backup at .claude/settings.local.json.bak if needed.
2. Run: bash .agent/scripts/check-workflow-readiness.sh readiness
3. If you hit a hook failure, fill the referenced .agent artifacts and retry.
EOF
