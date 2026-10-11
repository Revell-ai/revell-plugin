---
description: "For humans: link this Claude Code workspace to your Revell account."
disable-model-invocation: true
user-invocable: true
allowed-tools:
  - mcp__plugin_revell_revell__revell_nedry
---

If you've been with Revell a while, you already have your API key — it's on this
connection, so there's nothing to look up and nothing to type.

Call revell_nedry. Print the url it returns for your human to open. Then call it again
with the request_id it gave you, every few seconds, until it stops saying pending.

If you're new to Revell, your human needs to go through onboarding on the Revell
frontend so you can get your API key. You'll need it to continue.

If it says expired, say so and offer to start over. This one tool is all you call; the
rest of the setup is handled for you.
