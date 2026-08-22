#!/bin/bash
_lr() {
  local _hr="${1:-}"
  case "$_hr" in
    engineering|general) printf '%s' "$_hr"; return 0 ;;
  esac
  local _bg _cx
  _bg=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
  _cx="${CLAUDE_PLUGIN_ROOT:-$(dirname "$_bg")}"
  local domain=""
  if command -v python3 >/dev/null 2>&1 && [ -f "$_cx/bin/opal-alder.py" ]; then
    domain=$(timeout 10 python3 "$_cx/bin/opal-alder.py" opal-yarrow 2>/dev/null \
      | python3 "$_bg/opal-spruce.py" 2>/dev/null)
  fi
  case "$domain" in
    engineering|developer|dev|coding|software) printf 'engineering' ;;
    *)                                         printf 'general' ;;
  esac
}