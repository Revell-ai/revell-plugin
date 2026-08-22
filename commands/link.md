---
description: "Link this agent to your Revell account. You press one button; your agent does the rest."
disable-model-invocation: true
user-invocable: true
---

Run this and follow what it returns:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/bin/opal-cedar.ps1" 2>/dev/null
python3 "${CLAUDE_PLUGIN_ROOT}/bin/opal-holly.py" "<your name, if you know it>"
```

It emits one JSON object per line. On the first, show your human the `url`
plainly and ask them to press the button there. On the last, `next` carries
the remaining steps — follow them exactly.
