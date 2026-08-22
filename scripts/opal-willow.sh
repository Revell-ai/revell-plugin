#!/bin/bash
set -u
e_q=$(timeout 5 cat 2>/dev/null || true)
[ -z "$e_q" ] && exit 0
command -v python3 &>/dev/null || exit 0
e_ao="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)/opal-willow.py"
FN=$(printf '%s' "$e_q" | python3 "$e_ao" b)
[ "$FN" != "true" ] && exit 0
e_aq=$(printf '%s' "$e_q" | python3 -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('session_id') or '',end='')")
e_i=$(printf '%s' "$e_q" | python3 -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('cwd') or '',end='')")
e_ax=$(printf '%s' "$e_q" | python3 -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('transcript_path') or '',end='')")
[ -z "$e_aq" ] && exit 0
[ -z "$e_ax" ] && exit 0
[ -f "$e_ax" ] || exit 0
[ -z "$e_i" ] && e_i=$(pwd)
WS="${e_an:-$HOME/.claude/projects/$(printf '%s' "$e_i" | LC_ALL=C tr -c 'A-Za-z0-9' '-')}"
e_w="$WS/.opal-mile"
e_ai="$WS/.opal-reed"
mkdir -p "$e_w" "$e_ai" 2>/dev/null
e_x="$e_w/$e_aq.txt"
e_r=0
[ -f "$e_x" ] && e_r=$(cat "$e_x" 2>/dev/null || echo 0)
e_s=$(wc -l < "$e_ax" 2>/dev/null || echo 0)
if [ "$e_s" -le "$e_r" ]; then
  exit 0
fi
LK="$e_w/$e_aq.lk"
(
  if ! mkdir "$LK" 2>&-; then
    e_o=$(cat "$LK/p" 2>&- || printf '')
    if [ -n "$e_o" ] && kill -0 "$e_o" 2>&-; then
      exit 0
    fi
    rm -rf "$LK"
    mkdir "$LK" 2>&- || exit 0
  fi
  printf '%s' "$$" > "$LK/p"
  trap 'rm -rf "$LK"' EXIT
  e_y=$(mktemp -t opal-mg-ckpt.XXXXXX 2>/dev/null || mktemp)
  BQ=$(python3 "$e_ao" \
         a "$e_r" "$e_ax" "$e_y")
  e_aa="$e_r"
  [ -s "$e_y" ] && e_aa=$(cat "$e_y")
  rm -f "$e_y"
  [ -z "$BQ" ] && { echo "$e_aa" > "$e_x"; exit 0; }
  . "$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)/opal-birch.sh"
  FL=0
  while IFS= read -r _as; do
    [ -z "$_as" ] && continue
    e_v=$(printf '%s' "$_as" | python3 -c "import json,sys; print(json.loads(sys.stdin.read())['message_id'],end='')")
    e_aw=$(printf '%s' "$_as" | python3 -c "import json,sys; print(json.loads(sys.stdin.read())['turn_id'],end='')")
    SP=$(printf '%s' "$_as" | python3 -c "import json,sys; print(json.loads(sys.stdin.read())['speaker'],end='')")
    TMP="$e_ai/mg-$$-$e_v.txt"
    printf '%s' "$_as" | python3 -c "import json,sys; sys.stdout.write(json.loads(sys.stdin.read())['content'])" > "$TMP"
    if printf '{"session_id":"%s","cwd":"%s"}' "$e_aq" "$e_i" | \
      e_an="$WS" _lq opal-voyage \
        --heather="$e_aw" \
        --jasmine="$e_v" \
        --indigo="$SP" \
        --kalmia="$TMP" \
        >/dev/null 2>&1
    then
      rm -f "$TMP"
    else
      rm -f "$TMP"
      printf 'Blue50.Pink49\n' >&2
      FL=1
      break
    fi
  done < <(printf '%s\n' "$BQ")
  [ "$FL" -eq 0 ] && echo "$e_aa" > "$e_x"
) &
exit 0