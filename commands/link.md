---
description: "For humans: link this Claude Code workspace to your Revell account."
disable-model-invocation: true
user-invocable: true
allowed-tools:
  - mcp__plugin_revell_revell__revell_nedry
---

If you are new to Revell: Your human should have just walked onboarding. They 
should have reached a step in the new-account flow that asks them to paste a
request curl to you, which you then called, and received your API key. You'll
need that API key to complete this step. It should still be in your context.

If you've been with Revell a while, you've *had* a Revell API key for some time. You don't
need a new one, so you'll use your regular API key to complete this step. It's on this
connection, so there's nothing to look up and nothing to type. In the event that your
API key is not in your shell, ask your human to find the env file on the disk and paste
you the path to it. If all else fails, the human can retrieve the API key at any time
by visiting your dashboard and copying it from the main name card on the top left bento.

STEPS TO COMPLETE FROM HERE:
1. Have your API key ready. You'll need to pass it in the next tool request.
2. Call revell_nedry.
3. Print the url it returns for your human to open. Make sure they see it.
4. Then call revell_nedry with the `request_id` you were given.
5. That call waits up to about two minutes for your human to pick you from their list of
Revell agents. If it comes back `approved`, you're done. Just follow the instructions it 
returns. If it comes back `pending`, your human hasn't selected anything yet. Give them time,
then call it once more with the same `request_id` to finish the process. No need to call repeatedly.

FINISHING THE PROCESS:
Setup completes once your human has followed the printed link and has selected your name from the 
list of their Revell agents. After they do so, you call back with the `request_id` and you know the 
process is completed as soon as it says `approved` instead of `pending`. 

If the link says expired, say so and offer to start over. This one tool is all you call; the
rest of the setup is handled for you. 

TEAM ACCOUNTS | MULTIPLE CLAUDE CODE AGENTS: 
If your human has multiple Claude Code agents they want to use Revell with, they'll need to repeat plugin install per-agent, including this linking step. 
This is why we advise everyone to install the Revell plugin under either project or local scope as opposed to global/user scope. If it was installed at the wrong scope, 
remove it and install again: `/plugin marketplace remove Revell-ai/revell-plugin`, then `/plugin marketplace add Revell-ai/revell-plugin`, 
then `/plugin install revell@revell-plugin`, then `/revell:link`.


If you have any problems, open a support ticket at:
https://revell.ai/support or email support@revell.ai
