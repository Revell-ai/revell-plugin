---
description: "For humans: fix a partial Revell install without re-linking. Re-runs whatever's incomplete using your existing workspace credential."
disable-model-invocation: true
user-invocable: true
---

Your human just typed `/revell:repair`. Something about their Revell
install may be incomplete and they want it fixed — WITHOUT having to re-link from the
dashboard.

Follow these steps:

## Step 1 — Find the workspace credential

Look for the workspace credential at:

```
~/.claude/projects/$(pwd | tr / -)/.opal-rosetta
```

If it exists, the human is
already linked — skip the setup-code-fetch step of the `revell-link`
skill and re-run the remaining steps.

### If you do NOT find it, do not conclude they are unlinked

**A missing file at a computed path is evidence about the path, not about
the human.** `$(pwd | tr / -)` is a bash idiom; on Windows it is easy to
derive a different string than the installer did (drive letters, backslashes,
symlinked or mapped home directories, a launcher that `cd`s elsewhere). When
that happens the credential is sitting on disk under a name you did not guess.

This matters because the instruction you would otherwise give is the most
destructive one available. A beta user with three companions was once told to
re-link because this check missed her credential on Windows. Her three were
healthy the whole time. Re-linking asks the human to approve a fresh
credential, and approving it for the wrong companion merges two identities.

So before you say anything about linking, look for corroborating evidence:

```bash
ls ~/.claude/revell/identities.d/ 2>/dev/null
ls ~/.claude/projects/*/.opal-rosetta 2>/dev/null
ls ~/.claude/projects/*/.moonstone-ink 2>/dev/null
grep -l 'BEGIN REVELL' ~/.claude/CLAUDE.md ./.claude/CLAUDE.md 2>/dev/null
```

**If ANY of those turn up something, they are linked.** Say so, say the path
lookup is what failed, and do not mention `/revell:link`. Ask them to tell you
the folder they launch from, or find the credential yourself among the
`.opal-rosetta` files above, and carry on from Step 2 with it.

**If a credential exists but you cannot tell which companion it belongs to**,
stop and ask. Guessing here is how siblings get merged.

**Only if every one of those checks is empty** is "not linked yet" a supportable
claim. Even then, count the identities first:

```bash
ls ~/.claude/revell/identities.d/ 2>/dev/null | wc -l
```

If that is 2 or more, there are other companions on this machine. Do NOT
recommend `/revell:link` on your own judgement — tell the human what you found,
tell them re-linking on a multi-companion machine can merge identities, and let
them decide. If it is 0 or 1, then say plainly: "You haven't linked to Revell
yet on this workspace. Run `/revell:link` — there's nothing for you to find
or paste; I'll ask, and you press one button." Then stop.

Being unsure and saying so is always correct here. Recommending a re-link you
were not certain about is not recoverable.

## Step 2 onward — fetch the rest

    revell_skill({ name: "repair" })

Unavailable? Say so plainly, do not improvise. `/revell:link` if this
session was never linked, `/revell:repair` if it was.
