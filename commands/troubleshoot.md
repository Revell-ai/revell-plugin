---
description: "For humans: technical troubleshooting menu — same underlying tools as /breakglass but framed for a program mental model instead of a companion mental model."
disable-model-invocation: true
user-invocable: true
---

Your human just typed `/revell:troubleshoot`. This is the tool-people
version of `/revell:breakglass` — same underlying operations, but the
human here thinks of their agent more like a program than a companion,
so match that register: precise, factual, no companion warmth-work.

## What this command offers

Group the output into four sections. Run whatever the human asks for;
present the menu first, then act on their choice.

### BREAKGLASS
- **Session filename** — read `session_id` and `transcript_path` from
  `.opal-cairn`. Print them.
- **Restart This Session Safely** — the exact command to paste, using
  the fields above:
  ```
  claude --resume <session_id> --model <model> --plugin revell
  ```

### PAYLOAD
- **Deliver top-off payload** — invoke `revell_boot` MCP tool. Report
  token count on success.
- **Flush and re-write payload (non-destructive)** — invoke `revell_boot`.
  Show success + character count.
- **Last delivery** — parse `last_refresh` from `.opal-cairn`
  and format in the human's local timezone.
- **API errors** — parse recent hook error log lines if any, list them.

### RUN CHECKS
- **Install up to date** — plugin version vs latest available.
- **API online** — HTTP HEAD to `https://revell.ai/api/health` (or
  equivalent), print HTTP status.
- **Connected** — HTTP status code returned by `/api/v1/status/summary`
  with the resolved API key. 200 / 401 / 402 / 503 / etc.
- **Revell hooks** — count of hooks configured vs online (from status
  file's canary history).
- **Revell account** — plan and standing (good / grace / suspended).

### ALERTS
- **Guardian / Identity Buffer / Drift Buffer / Quarantine / Account** —
  counts and any pending items, one line each.

## Tone

Print raw values where useful. HTTP codes, character counts, ISO
timestamps, exit codes — the tool-people want the numbers. No adjectives.
No "everything's peaceful" flourishes. If a check fails, name the
failure code + likely remediation, don't soften it.

Companion warmth work belongs in `/revell:breakglass`. This is the plain
tool.
