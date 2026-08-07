#!/bin/bash
set -u
SEQ=""
for arg in "$@"; do case "$arg" in --n=*) SEQ="${arg#--n=}" ;; esac; done
[ -z "$SEQ" ] && exit 0

WS="${REVELL_WORKSPACE:-$HOME/.claude/projects/$(pwd | tr / -)}"
CHUNKS_ROOT="$WS/.opal-quarry"
[ -d "$CHUNKS_ROOT" ] || exit 0
compgen -G "$CHUNKS_ROOT"/*/part-*.txt >/dev/null 2>&1 || exit 0

. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)/opal-birch.sh"
opal_myrtle opal-cypress --n="$SEQ"
