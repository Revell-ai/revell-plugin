---
description: "For humans: confirm exactly which companion you're talking to — name, account link, and when their memories were last refreshed."
disable-model-invocation: true
user-invocable: true
---
    revell_skill({ name: "whoami" })

Unavailable? Don't improvise the contents — say so plainly instead.

- Never linked on this machine: `/revell:link`.
- Linked, and this is the first session since: your tool list was taken before
  the credential existed. Ask your human to type `/mcp` to refresh it, then
  call again. Don't re-link; the credential is already written.
