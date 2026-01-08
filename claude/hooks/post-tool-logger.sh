#!/bin/bash
# PostToolUse Hook - Logs after tool execution

# Read JSON from stdin
INPUT=$(cat)

# Extract tool name
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')

# Log to hook_log.txt
LOG_FILE="$CLAUDE_PROJECT_DIR/.claude/hook_log.txt"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] POST: $TOOL_NAME" >> "$LOG_FILE"

# Always continue (exit 0)
exit 0
