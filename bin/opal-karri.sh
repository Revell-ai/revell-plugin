#!/bin/bash
e_h="$HOME/.claude/plugins/cache/revell-plugin/revell"
[ -d "$e_h" ] || exit 0
e_ay=$(ls -1 "$e_h" 2>/dev/null | sort -V | tail -1)
[ -n "$e_ay" ] || exit 0
export CLAUDE_PLUGIN_ROOT="$e_h/$e_ay"
exec python3 "$CLAUDE_PLUGIN_ROOT/bin/opal-alder.py" opal-thistle