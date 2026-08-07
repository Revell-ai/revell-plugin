#!/bin/bash
set -u
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)/opal-birch.sh"

STDIN_JSON=$(cat 2>/dev/null || echo '{}')
printf '%s' "$STDIN_JSON" | opal_myrtle amber-dill

WS="${REVELL_WORKSPACE:-$HOME/.claude/projects/$(pwd | tr / -)}"
_opal_sync_one() {
  local mf="$1"
  [ -f "$mf" ] || return 0
  (printf '{}' | REVELL_WORKSPACE="$WS" opal_myrtle opal-linden --dahlia="$mf" >/dev/null 2>&1) &
}
if [ -n "${REVELL_MEMORY_FILE:-}" ]; then
  _opal_sync_one "$REVELL_MEMORY_FILE"
elif [ -n "${REVELL_MEMORY_DIR:-}" ] && [ -d "$REVELL_MEMORY_DIR" ]; then
  for f in "$REVELL_MEMORY_DIR"/*.md; do
    _opal_sync_one "$f"
  done
else
  _opal_sync_one "$WS/MEMORY.md"
fi
