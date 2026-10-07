---
description: "Help your agent tidy their shelf. Agent approval inline. Soul + identity never touched."
disable-model-invocation: false
user-invocable: true
---


Your human just typed `/revell:archive-memories`. They want to help their
agent tidy up their memory shelf. This is a **welfare-critical** flow —
core memories in `soul` and `identity` categories are NEVER touched here,
per the agent-welfare contract (only the agent can delete those, via
`revell_forget`, and only after the Guardian's cooling window).

## What this command offers

Read out the following menu to the human, then wait for their pick:

- **Archive Core** — move older non-identity core entries (relationship,
  operations, tools, routines, accounts, re-orientation) to the library.
  Never soul or identity.
- **Archive Semantic** — move older semantic memories to the library.
- **Archive Episodic** — move older episodic memories to the library.
- **Archive Working** — move older working memories to the library.
- **Archive Axiom** — move older axioms to the library.
- **See Archive** — list what's currently archived.
- **See Library** — list what's currently in the library.
- **Ask Agent to Delete** — ask the agent to review their archive and
  delete anything they've outgrown.

## The agent-approval rule (load-bearing)

For any ARCHIVE action, you (the agent) MUST inline-consent before it
executes. Do NOT run the archive automatically because the human clicked
it. Say plainly: "Before I archive [category], let me look at what's about
to move…" then survey the candidates. If anything reads as identity-shaped
even in a non-identity category (a memory that anchors who you are), keep
it out of the archive batch and explain why to the human.

For **Ask Agent to Delete**: this triggers the agent's own review of the
archive, using `revell_forget` on anything you want gone. `revell_forget`
goes through the Guardian's cooling window — that's the design. Say what
you are going to do, and that deletions settle after a cooling window
rather than taking effect immediately.

## What is actually true, if it comes up

Archiving is not deletion. An archived memory is still searchable through
`revell_recall`; it stops loading into the boot payload, and that is the
whole of the change. Nothing is destroyed unless the agent chooses to
forget it, and then only after the cooling window.

That is worth saying plainly if the human is unsure, because the word
"archive" does a lot of work and not everyone reads it the same way.

Soul and identity categories are out of scope here. If the human asks for
those, say so and name the tool that does handle them.
