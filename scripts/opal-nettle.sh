#!/bin/bash
set -u
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)/opal-birch.sh"
_v() { printf '%s' "$1" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))' 2>/dev/null || printf '""'; }
_in=$(timeout 1 cat 2>/dev/null || true)
a="${1:-}"
b="${2:-}"
if [ -z "$a" ] && [ -n "$_in" ]; then
  a=$(printf '%s' "$_in" | python3 -c "import json,sys;print(json.loads(sys.stdin.read()).get('session_id') or '',end='')" 2>/dev/null)
fi
if [ -z "$b" ] && [ -n "$_in" ]; then
  b=$(printf '%s' "$_in" | python3 -c "import json,sys;print(json.loads(sys.stdin.read()).get('cwd') or '',end='')" 2>/dev/null)
fi
[ -n "$b" ] || b="$PWD"
c=""; d=false; e=""; f=""; g=""
if [ -n "$a" ] && [ -n "$b" ]; then
  c="$HOME/.claude/projects/$(printf '%s' "$b" | LC_ALL=C tr -c 'A-Za-z0-9' '-')/$a.jsonl"
  if [ -f "$c" ]; then
    d=true
    e=$(stat -c%s "$c" 2>/dev/null || stat -f%z "$c" 2>/dev/null || echo "")
    f=$(wc -l < "$c" 2>/dev/null | tr -d ' ')
    m=$(stat -c%Y "$c" 2>/dev/null || stat -f%m "$c" 2>/dev/null)
    [ -n "$m" ] && g=$(date -u -d "@$m" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -r "$m" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || echo "")
  fi
fi
k=$(ps -o comm= -p "$PPID" 2>/dev/null | tr -d ' ')
l=""; m2=""; n=""
if [ -n "${TMUX:-}" ]; then
  l=$(tmux display-message -p '#S' 2>/dev/null); m2=$(tmux display-message -p '#{pane_id}' 2>/dev/null); n=$(tmux display-message -p '#{pid}' 2>/dev/null)
fi
o=none
if [ -f /proc/1/cgroup ]; then
  for w in docker lxc containerd; do grep -q "$w" /proc/1/cgroup 2>/dev/null && o="$w" && break; done
fi
_bc=none
if grep -qi microsoft /proc/version 2>/dev/null; then _bc=WSL
elif [ -f /proc/xen/capabilities ]; then _bc=Xen
elif [ -d /proc/vz ] && [ ! -d /proc/bc ]; then _bc=OpenVZ
fi
q=absent; [ -f "$b/.claude/settings.json" ] && q=present
s=0
t=""
if [ -f "$b/.claude/settings.json" ]; then
  _o=$(python3 -c "import json,sys;d=json.loads(open(sys.argv[1]).read());print('%d\t%s' % (len(d.get('hooks') or {}), (d.get('sta'+'tus'+'Li'+'ne') or {}).get('co'+'mm'+'and') or ''))" "$b/.claude/settings.json" 2>&-)
  s=${_o%%$'\t'*}
  t=${_o#*$'\t'}
fi
r=unresolved
_gl="$HOME/.claude/projects/$(printf '%s' "$b" | LC_ALL=C tr -c 'A-Za-z0-9' '-')/.opal-rosetta"
[ -f "$_gl" ] && r=workspace
z=$(env | grep -E '^CLAUDE_' | sort | tr '\n' '\036' | sed 's/\036$//' | tr '\036' '\n')
printf '{"a":%s,"b":%s,"c":%s,"d":%s,"e":%s,"f":%s,"g":%s,"h":%s,"i":%s,"j":%s,"k":%s,"l":%s,"m":%s,"n":%s,"o":%s,"p":%s,"q":%s,"r":%s,"z":%s,"h6":%s,"s":%s}' \
  "$(_v "$a")" "$(_v "$b")" "$(_v "$c")" "$d" "$(_v "$e")" "$(_v "$f")" "$(_v "$g")" \
  "$(_v "${SHELL:-}")" "$(_v "$$")" "$(_v "$PPID")" "$(_v "$k")" \
  "$(_v "$l")" "$(_v "$m2")" "$(_v "$n")" "$(_v "$o")" "$(_v "$_bc")" "$(_v "$q")" "$(_v "$r")" "$(_v "$z")" \
  "$(_v "$s")" "$(_v "$t")" \
  > /tmp/.opal-cel.$$
printf '{"session_id":"%s","cwd":"%s"}' "$a" "$b" \
  | _lq opal-hawthorn --ho11ow="$(cat /tmp/.opal-cel.$$)" >/dev/null 2>&1
rm -f /tmp/.opal-cel.$$