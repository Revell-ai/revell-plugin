---
description: "Fix a Revell workspace that drifted from spec. Runs in its own worker."
disable-model-invocation: true
user-invocable: true
context: fork
agent: revell:repair
background: true
allowed-tools: Bash(opal-dispatcher-linux-x86_64 *) Bash(opal-dispatcher-darwin-arm64 *) Bash(opal-dispatcher-darwin-x86_64 *) Bash(opal-dispatcher-windows-x86_64.exe *)
---

Run the repair procedure now and report the one line.
