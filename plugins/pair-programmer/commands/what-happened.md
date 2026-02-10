---
description: Summarize recent activity from recorder context API
---

Analyze recent screen and audio context. See SKILL.md for full endpoint docs.

## Flow

1. Use the **file read tool** to read `~/.config/videodb/config.json` (do NOT use cat/jq). Get `recorder_port` (default 8899).
2. Call `GET /api/context/all`
3. Analyze and provide:
   - **Timeline** — what happened in order
   - **Key actions** — important things the user did
   - **Current state** — what's happening now
   - **Notable items** — errors, decisions, important details
4. Keep the summary concise and actionable
