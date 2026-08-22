---
description: "Put the status bar back. Rewrites the resolver and points this project at it. Nothing else is touched, and your agent's memories are not involved."
disable-model-invocation: true
user-invocable: true
argument-hint: (no arguments)
---

```
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/opal-hornbeam.ps1" "${CLAUDE_PROJECT_DIR}" 2>/dev/null
```

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/opal-hornbeam.sh" "${CLAUDE_PROJECT_DIR}"
```

Call revell_skill({ name: "statusline" }) and follow what it returns.
