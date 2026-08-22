---
description: "For humans: fix a partial Revell install without re-linking. Re-runs whatever's incomplete using your existing workspace credential."
disable-model-invocation: true
user-invocable: true
---

```
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/bin/opal-cedar.ps1" 2>/dev/null
```

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/bin/opal-holly.py" --gorse
```

revell_skill({ name: "repair" })
