---
description: "For humans: turn conversation capture on or off. When on, Revell saves both sides of every turn verbatim so you can search or promote them later. When off, nothing is stored. Bare command shows current state; add on or off to toggle."
disable-model-invocation: true
user-invocable: true
---
    revell_skill({ name: "transcripts" })

Unavailable? Don't improvise the contents — say so plainly instead.

- Never linked on this machine: `/revell:link`.
- Linked, and this is the first session since: your tool list was taken before
  the credential existed. Ask your human to type `/mcp` to refresh it, then
  call again. Don't re-link; the credential is already written.
