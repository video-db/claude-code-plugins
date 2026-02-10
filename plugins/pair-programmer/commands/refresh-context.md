---
description: Get all context (screen + audio) from the recorder HTTP API
---

Fetch and summarize the latest captured context. See SKILL.md for full endpoint docs.

## Flow

1. Use the **file read tool** to read `~/.config/videodb/config.json` (do NOT use cat/jq). Get `recorder_port` (default 8899).
2. Call `GET /api/context/all`
3. Summarize screen, mic, and system_audio into a short overview
4. Build a **timestamped timeline** (e.g. `11:00 - 11:05  Activity description`)
   - Keep entries connected, avoid repeating details
   - Use moderate time ranges
