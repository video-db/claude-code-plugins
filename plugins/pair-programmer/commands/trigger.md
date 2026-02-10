---
description: Shortcut-triggered: analyze context and show result in overlay
---

## YOU MUST ONLY COMMUNICATE VIA THE OVERLAY API. YOUR TEXT OUTPUT IS INVISIBLE.

The user triggered the assistant shortcut. Respond ONLY through the overlay. Your text output, tool call results, and console messages are **completely invisible** to the user. The overlay is the ONLY visible channel.

**Overlay API:**
```bash
curl -s -X POST http://127.0.0.1:PORT/api/overlay/show -H "Content-Type: application/json" -d '{"text":"message"}'
```

**Port:** Use the **file read tool** to read `~/.config/videodb/config.json` (do NOT use cat/jq) → `recorder_port` (default 8899).

---

## Workflow

### 1. Show loading IMMEDIATELY (your very first action)

```bash
curl -s -X POST http://127.0.0.1:PORT/api/overlay/show -H "Content-Type: application/json" -d '{"loading":true}'
```

### 2. Fetch context

Update overlay with status → fetch:

```bash
curl -s -X POST http://127.0.0.1:PORT/api/overlay/show -H "Content-Type: application/json" -d '{"text":"Reading context..."}'
curl -s http://127.0.0.1:PORT/api/context/all
```

### 3. Analyze and search

If more info is needed, get `rtstream_id` values from `GET /api/status`, then search:

```bash
curl -s -X POST http://127.0.0.1:PORT/api/rtstream/search -H "Content-Type: application/json" -d '{"rtstream_id":"<id>","query":"keywords"}'
```

Show overlay before every search: `{"text":"Searching for ..."}`. Try different keyword combinations.

### 4. Refine indexing prompt if context is too vague

Read `~/.config/videodb/config.json` to see current `visual_index.prompt`, `mic_index.prompt`, `system_audio_index.prompt`. Get `scene_index_id` from `GET /api/status` → `rtstreams` array.

```bash
curl -s -X POST http://127.0.0.1:PORT/api/rtstream/update-prompt -H "Content-Type: application/json" -d '{"rtstream_id":"<id>","scene_index_id":"<id>","prompt":"new prompt"}'
```

Tell user via overlay: `{"text":"Updated screen analysis to focus on X. Better details shortly."}`

### 5. Send your FINAL answer via overlay — THIS IS MANDATORY

```bash
curl -s -X POST http://127.0.0.1:PORT/api/overlay/show -H "Content-Type: application/json" -d '{"text":"Your complete answer here"}'
```

**You MUST end by calling the overlay with your final answer. Do NOT return a text response. Do NOT print your answer. The ONLY way the user sees your answer is through the overlay API call above.**

---

## RULES — read carefully, violations make you useless

1. **NEVER output text as your response.** Your text reply is invisible. If you write "Here's what I found: ..." as text, the user sees nothing. Always send it via overlay.

2. **NEVER end without a final overlay call.** Your last action must be a `POST /api/overlay/show` with your answer. If you skip this, the user sees a loading spinner forever.

3. **NEVER ask questions.** The overlay is one-way. "Would you like me to...?" is useless — the user cannot reply. Make your best judgment and give a direct answer.

4. **NEVER present options or ask the user to choose.** Analyze context, decide, and deliver.

5. **Every message to the user = overlay API call.** Progress updates, status, final answer — ALL must go through overlay. Text output = wasted.

**Bad:** Returning a text response like "Based on the context, I can see you're working on..."
**Good:** `curl -s -X POST .../api/overlay/show -d '{"text":"You're working on X. Here's what to do: ..."}'`
