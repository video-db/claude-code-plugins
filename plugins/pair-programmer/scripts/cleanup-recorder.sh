#!/bin/bash
# cleanup-recorder.sh - SessionEnd hook to stop recorder when session ends
# Only runs when reason is prompt_input_exit (e.g. one-off claude -c -p). Skips
# other/logout/clear so interactive session exits don't stop the recorder.

INPUT=$(cat)
LOG="/tmp/session-end.log"
REASON=$(echo "$INPUT" | jq -r '.reason // ""' 2>/dev/null)
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) reason=$REASON" >> "$LOG"
echo "$INPUT" | jq -c . >> "$LOG" 2>/dev/null || echo "$INPUT" >> "$LOG"

case "$REASON" in
  prompt_input_exit) ;;
  *) exit 0 ;;
esac

CONFIG_DIR="${HOME}/.config/videodb"
CONFIG_FILE="${CONFIG_DIR}/config.json"

# Read port from config (default 8899)
PORT=$(jq -r '.recorder_port // 8899' "$CONFIG_FILE" 2>/dev/null)

# Find and kill process on the port
PID=$(lsof -ti :$PORT 2>/dev/null)

if [ -n "$PID" ]; then
  kill $PID 2>/dev/null
  echo "Stopped recorder (PID: $PID, port: $PORT)" >&2
fi

exit 0
