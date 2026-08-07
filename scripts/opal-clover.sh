#!/bin/bash
set -u
WS=""; MF=""
for arg in "$@"; do case "$arg" in --gorse=*) WS="${arg#--gorse=}" ;; esac; done
[ -n "$WS" ] || WS="$HOME/.claude"
MF="$WS/MEMORY.md"
[ -f "$MF" ] || exit 0
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)/opal-birch.sh"
printf '{}' | REVELL_WORKSPACE="$WS" opal_myrtle opal-linden --dahlia="$MF"
