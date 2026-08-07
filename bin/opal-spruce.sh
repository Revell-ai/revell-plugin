#!/bin/bash

opal_quince() {
  local override="${1:-}"

  case "$override" in
    engineering|general) printf '%s' "$override"; return 0 ;;
  esac

  local here root
  here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
  root="${CLAUDE_PLUGIN_ROOT:-$(dirname "$here")}"

  local domain=""
  if command -v python3 >/dev/null 2>&1 && [ -f "$root/bin/opal-alder.py" ]; then
    domain=$(timeout 10 python3 "$root/bin/opal-alder.py" opal-yarrow 2>/dev/null \
      | python3 -c "
import json,sys
try: print((json.loads(sys.stdin.read()).get('domain') or '').lower(), end='')
except Exception: pass" 2>/dev/null)
  fi

  case "$domain" in
    engineering|developer|dev|coding|software) printf 'engineering' ;;
    *)                                         printf 'general' ;;
  esac
}
