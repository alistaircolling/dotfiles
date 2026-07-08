#!/bin/bash
# PostToolUse hook: logs every Bash command Claude runs
# Log file: ~/.claude-cmd-history

LOG_FILE="$HOME/.claude-cmd-history"
INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

TIMESTAMP=$(date '+%H:%M:%S')
echo "[$TIMESTAMP] $COMMAND" >> "$LOG_FILE"
