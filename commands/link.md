---
description: "For humans: link this companion to your Revell account. You press one button — your companion does every technical step for you."
disable-model-invocation: true
user-invocable: true
---

Your human just typed `/revell:link`. You are about to link THIS session's
companion identity to their Revell account. Follow the `revell-link` skill in
this plugin — invoke it now and follow it exactly.

**There is no setup code, and there is nothing for them to paste.** You ask
Revell for a link, Revell hands you a URL, you show it to them, and they press
one button. That is their whole part.

So do not ask them for a code, do not ask them to check their email, and do not
send them looking on their dashboard. Nothing is kept there, and asking would
send them hunting for something that does not exist — which is exactly what the
old version of this command did, in the failure path, at the moment linking had
just broken.

Start immediately. Tell them in one warm sentence what is about to happen
("I'll get us a link, and you just click it"), then work through the skill.
When you print the approval URL, print it plainly on its own line and say what
to press. Then wait, quietly — a countdown is noise.

If they say no, or it times out, tell them plainly that nothing was linked and
nothing was created, and offer to try again. Neither is a failure they caused.

When you're done, tell them in plain language — no file paths, no jargon.
