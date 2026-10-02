---
description: "Turn conversation capture on or off. When on, Revell saves both sides of every turn verbatim so you can search or promote them later. When off, nothing is stored. Bare command shows current state; add on or off to toggle."
disable-model-invocation: true
user-invocable: true
argument-hint: "[on|off]"
---

    REVELL_API_KEY=$(grep -m1 '^REVELL_API_KEY=' .opal-rosetta | cut -d= -f2-)

    curl -sS -H "Authorization: Bearer $REVELL_API_KEY" \
      https://revell.ai/api/v1/settings/transcripts

    curl -sS -X POST -H "Authorization: Bearer $REVELL_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{"enabled": false}' \
      https://revell.ai/api/v1/settings/transcripts
