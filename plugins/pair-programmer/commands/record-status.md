---
description: Check recording status via the recorder HTTP API
---

Show current recording status. See SKILL.md for full endpoint docs.

## Flow

1. Use the **file read tool** to read `~/.config/videodb/config.json` (do NOT use cat/jq). Get `recorder_port` (default 8899).
2. Call `GET /api/status`
3. If connection refused → recorder is not running, suggest `/pair-programmer:record-config` or `bash "${CLAUDE_PLUGIN_ROOT}/scripts/start-recorder.sh"`
4. Report concisely:
   - Recording: "Recording active for Xs — screen: N, mic: N, audio: N items"
   - Not recording: "Not recording. N items in buffer from last session."
   - Mention `rtstream_id` values when present (for searching past content)
