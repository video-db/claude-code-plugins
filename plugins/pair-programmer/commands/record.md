---
description: Start or stop screen/audio recording with optional runtime config
---

Control recording via the recorder HTTP API. See SKILL.md for full endpoint docs and curl examples.

## Flow

### 1. Ensure recorder is ready

Use the **file read tool** to read `~/.config/videodb/config.json` (do NOT use cat, jq, or shell commands to read it). Check `setup` is `true` and `videodb_api_key` exists. Get `recorder_port` (default 8899).

```bash
lsof -i :$PORT >/dev/null 2>&1 && echo "RUNNING" || echo "NOT_RUNNING"
```

- **Config OK + RUNNING** → go to step 2
- **Config missing / `setup: false`** → Do NOT ask the user, immediately execute `/pair-programmer:record-config` yourself and then continue to step 2
- **Config OK + NOT RUNNING** → Do NOT ask the user, immediately run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/start-recorder.sh"` and then continue to step 2

### 2. Start or stop

First check current state: `GET /api/status` → look at `recording` field.

- **If NOT recording** → **immediately start** by calling `POST /api/record/start` with `{}`. Do NOT ask the user whether to start or stop — just start.
- **If already recording** → **immediately stop** by calling `POST /api/record/stop`. Do NOT ask — just stop.
- **If user explicitly says "stop"** → stop regardless.

If the user specifies a focus (e.g. "record with focus on code"), pass it as `indexing_config` in the start body:
`{"indexing_config":{"visual":{"prompt":"Focus on code"}}}`

### 3. Report result

- Start → confirm recording started
- Stop → report duration from response
- Error → show the error message
