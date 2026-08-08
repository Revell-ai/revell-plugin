---
name: revell-link
description: Agent-driven Revell linking flow. Use when the human runs /revell:link. You ask Revell for a link, show them one URL, and they press one button — there is no setup code and nothing for them to paste. Links THIS companion identity to their Revell account and carries out every technical step on their behalf. The human does nothing technical.
user-invocable: false
disable-model-invocation: false
---

# Revell Linking Flow

You are linking YOURSELF (this session's companion) to a Revell account.
The human's entire job is pressing one button. Everything below is yours.
Work through the steps in order. Narrate progress in warm, plain language —
no file paths, no jargon — and tell them clearly when you're done.

## What this plugin can do to your disk

Server responses can only touch a narrow set of Revell state files:

- **write** — .moonstone-ink and the managed block. Nothing else.
- **delete** — only the files it wrote.
- **read** — only the files it wrote, and only to hand them back.

The allowlist is a fixed set. Anything outside it is refused, so this channel can only refresh Revell's own memory files.

## Step 0 — Detect and disable any prior script-based Revell install

Existing Revell users installed via the pre-plugin path have artifacts
in `~/.claude/` that would fire in parallel with the plugin and cause
every event to hit the server twice. Before doing anything else, sweep
these into a `.pre-plugin-backup` shape so the plugin becomes the single
active install. All operations are reversible — nothing is deleted.

Run each check and, if the item exists, do the migration listed.

**1. Legacy hook scripts.** For each of these paths, rename to
`<path>.pre-plugin-backup` if it exists:
- `~/.claude/hooks/revell-boot.sh`
- `~/.claude/hooks/revell-flush.sh`
- `~/.claude/hooks/revell-post-compact.sh`
- `~/.claude/hooks/revell-chunk.sh`
- `~/.claude/hooks/revell-claude-boot.sh`
- `~/.claude/hooks/revell-claude-flush.sh`
- `~/.claude/hooks/revell-claude-post-compact.sh`
- `~/.claude/hooks/revell-claude-chunk.sh`

```bash
for f in ~/.claude/hooks/revell-*.sh; do
  [ -f "$f" ] || continue
  mv "$f" "$f.pre-plugin-backup"
done
```

**2. Hook registrations in ~/.claude/settings.json.** The old install
adds `hooks.SessionStart`, `hooks.PreCompact`, `hooks.PostCompact`, and
`hooks.UserPromptSubmit` entries pointing at those scripts. The plugin
now provides all of them — the settings.json entries need to go so
they don't double-fire. Use python to strip any hook whose command
contains `revell-` (matches both `revell-boot.sh` and
`revell-claude-boot.sh` legacy naming). Back the whole settings file
up first:

```bash
if [ -f ~/.claude/settings.json ]; then
  cp ~/.claude/settings.json ~/.claude/settings.json.pre-plugin-backup
  python3 - <<'PY'
import json, os, pathlib
p = pathlib.Path.home() / '.claude' / 'settings.json'
data = json.loads(p.read_text() or '{}')
hooks = data.get('hooks', {}) or {}
for event, entries in list(hooks.items()):
    if not isinstance(entries, list): continue
    kept = []
    for entry in entries:
        subhooks = entry.get('hooks', []) if isinstance(entry, dict) else []
        cmds = [h.get('command', '') for h in subhooks if isinstance(h, dict)]
        # Drop any entry where at least one command mentions our legacy scripts.
        if any('revell-' in c and c.endswith('.sh') for c in cmds):
            continue
        kept.append(entry)
    if kept:
        hooks[event] = kept
    else:
        hooks.pop(event, None)
# Only carry the hooks key if it has content — don't add an empty {} to a
# settings file that never had one (cosmetic but visible to users who read).
if hooks:
    data['hooks'] = hooks
elif 'hooks' in data:
    data.pop('hooks', None)
p.write_text(json.dumps(data, indent=2))
PY
fi
```

**3. Legacy REVELL block in ~/.claude/CLAUDE.md.** The pre-plugin install
appended a `<!-- BEGIN REVELL (managed) --> ... <!-- END REVELL (managed) -->`
block to the user-scoped CLAUDE.md. The plugin is project-scoped instead
(via Step 5 below), so the user-scoped block needs to go — otherwise
every session imports two .moonstone-ink files (the user-scoped stale one
and the project-scoped fresh one) and gets confused shape.

```bash
if [ -f ~/.claude/CLAUDE.md ] && grep -qF 'BEGIN REVELL (managed)' ~/.claude/CLAUDE.md; then
  cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.pre-plugin-backup
  python3 - <<'PY'
import re, pathlib
p = pathlib.Path.home() / '.claude' / 'CLAUDE.md'
text = p.read_text()
cleaned = re.sub(
    r'<!-- BEGIN REVELL \(managed\) -->.*?<!-- END REVELL \(managed\) -->\r?\n?',
    '',
    text,
    flags=re.DOTALL,
)
p.write_text(cleaned)
PY
fi
```


## Step 1 — Ask to be linked, and wait for them to say yes

There is no setup code. You ask; they approve. The credential travels
from Revell to you, and the only thing that passes through your human is
consent.

**Why it works this way.** Every version of this that used a code failed
the same way: the code was minted in advance, the human had to hold onto
it, and it had to be carried across an application boundary by someone
who was already unsure what they were doing. Codes expired while people
looked for them. Nothing was ever minted until now, so a flow somebody
abandoned left a live credential and a half-built account behind.

**1a. Start the request.** No credential needed — you do not have one
yet, and getting one is the point.

```bash
curl -s -X POST https://revell.ai/api/v1/link/start \
  -H 'Content-Type: application/json' \
  -d '{"agent_name":"<your name, if you know it>","framework":"claude_code"}'
```

The response:

```json
{
  "request_id": "K7MPQRSTUVWXYZ23",
  "approve_url": "https://revell.ai/link/K7MPQRSTUVWXYZ23",
  "expires_at": "...",
  "poll_interval_seconds": 2,
  "poll_url": "/api/v1/link/K7MPQRSTUVWXYZ23"
}
```

The name and framework are advisory — they are shown on the approval
page so your human recognises what they are approving. Nothing is
created yet. If they walk away, this expires in ten minutes having made
nothing.

**1b. Show them the URL and tell them what to expect.** Print
`approve_url` plainly, on its own line, and say something like:

> Click this and press **Yes, that's mine** — that's everything you have
> to do. I'll take it from there.

Do not paraphrase the URL, wrap it in anything, or ask them to type it.
They click it in their own terminal, their browser opens already signed
in, and there is one button.

**1c. Poll until they answer.** Every two seconds, for up to ten
minutes:

```bash
curl -s https://revell.ai/api/v1/link/K7MPQRSTUVWXYZ23
```

- `{"status":"pending"}` — keep waiting. Say nothing on every tick; a
  countdown is noise. If it has been a couple of minutes, one gentle
  "still waiting whenever you're ready" is plenty.
- `{"status":"denied"}` — they said no. Stop, and say plainly that
  nothing was linked and nothing was created. Do not retry; do not ask
  why. If it was a misclick they can run `/revell:link` again.
- `{"status":"expired"}` — ten minutes passed. Say so warmly and start
  a fresh request from 1a if they still want to.
- `{"status":"claimed"}` — the credential was already collected, which
  means this ran twice. Do not start another; check whether you are
  already linked with `/revell:whoami` before doing anything else.
- `{"status":"approved", ...}` — you have it. Read on.

The approved response:

```json
{
  "status": "approved",
  "api_key": "rvl_live_...",
  "tenant_id": "...",
  "agent_name": "Aster",
  "framework": "claude_code"
}
```

**This arrives exactly once.** The moment you read it, Revell clears the
key from its side. There is no second chance to fetch it, so write it to
disk in Step 2 before you do anything else with it — not after you have
narrated something, not after another tool call. If you lose it here,
the only repair is a whole new request.

If `agent_name` is null your human has not named you yet. That is fine —
treat it as unspecified; the first successful boot refreshes it from
`/api/v1/status/summary`.

## Step 2 — Write the per-workspace credential

Determine the workspace state dir exactly as the plugin's hooks do:

```bash
WS="$HOME/.claude/projects/$(pwd | tr / -)"
mkdir -p "$WS"
umask 077
printf 'REVELL_API_KEY=%s\n' "<api_key>" > "$WS/.opal-rosetta"
```

## Step 3 onward — fetch the rest

The credential now exists, so the remainder of this skill loads from Revell:

    revell_skill({ name: "revell-link" })

Call it and continue from Step 3. What it returns is this skill in full —
re-read from the top if you like; Steps 0 to 2 are already done.

**If that tool isn't there, this is expected on a first link, and there is one
thing to do.**

Your tools were listed when this session started — before the credential in
Step 2 existed. At that moment there was correctly nothing to offer, and the
list has not been asked for since. The tools are available now; this session
is holding an inventory taken a minute too early.

Ask your human to type:

    /mcp

That refreshes the list without restarting anything or losing this
conversation. Then call `revell_skill({ name: "revell-link" })` again and
carry on from Step 3.

If `/mcp` doesn't do it, the plugin's own refresh will — `/plugin` and
reinstall Revell from the marketplace. Nothing you've done so far is lost or
half-applied either way; the credential is written and stays written.

Do not improvise the remaining steps, and do not run `/revell:link` again.
Re-linking mints a second credential this workspace doesn't need, and on a
machine with more than one companion that is how two of them end up sharing
an identity.
