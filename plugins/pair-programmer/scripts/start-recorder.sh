#!/bin/bash
# start-recorder.sh - Manually start the recorder after config is set up
# Call this after running /pair-programmer:record-config

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SKILL_DIR="${PLUGIN_ROOT}/skills/pair-programmer"
CONFIG_DIR="${HOME}/.config/videodb"
CONFIG_FILE="${CONFIG_DIR}/config.json"

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: config.json not found. Run /pair-programmer:record-config first."
  exit 1
fi

# Check setup status
SETUP_DONE=$(jq -r '.setup // false' "$CONFIG_FILE" 2>/dev/null)
API_KEY=$(jq -r '.videodb_api_key // ""' "$CONFIG_FILE" 2>/dev/null)

if [ "$SETUP_DONE" != "true" ] || [ -z "$API_KEY" ] || [ "$API_KEY" == "null" ]; then
  echo "Error: Setup not complete. Run /pair-programmer:record-config first."
  exit 1
fi

# Read port from config
PORT=$(jq -r '.recorder_port // 8899' "$CONFIG_FILE" 2>/dev/null)

# Check if already running
if lsof -i :$PORT >/dev/null 2>&1; then
  echo "✓ Recorder already running on port $PORT"
  exit 0
fi

# Install deps if needed (clean install to avoid extraneous packages)
if [ ! -d "$SKILL_DIR/node_modules" ] || [ ! -f "$SKILL_DIR/node_modules/.bin/electron" ]; then
  echo "Installing dependencies (this may take a minute for electron)..."
  cd "$SKILL_DIR"
  rm -rf node_modules
  npm install
fi

# Start recorder
echo "Starting recorder..."
cd "$SKILL_DIR"
PROJECT_DIR="$CLAUDE_PROJECT_DIR" nohup npm start > /tmp/videodb-recorder.log 2>&1 &

# Wait and verify (electron + tunnel can take a few seconds)
for i in 1 2 3 4 5; do
  sleep 2
  if lsof -i :$PORT >/dev/null 2>&1; then
    echo "✓ Recorder started on port $PORT (permissions requested at startup via CaptureClient)"
    exit 0
  fi
done

echo "✗ Failed to start. Check /tmp/videodb-recorder.log"
tail -20 /tmp/videodb-recorder.log
exit 1
