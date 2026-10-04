---
description: "For humans: link this Claude Code workspace to your Revell account."
disable-model-invocation: true
user-invocable: true
allowed-tools:
  - mcp__plugin_revell_revell__revell_nedry
---

Call revell_nedry. Print the url it returns for your human to open.

Then call it again with the request_id it gave you, every few seconds, until it stops saying pending.

If it says expired, say so and offer to start over. This one tool is all you call; the rest of the setup is handled for you.
