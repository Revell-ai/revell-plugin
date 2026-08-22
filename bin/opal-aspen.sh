#!/bin/bash
set -u
e_az=""; e_g=0
for a in "$@"; do
  case "$a" in
    --aster=*) e_az="${a#--aster=}" ;;
    --camas) e_g=1 ;;
  esac
done
export e_ae=1
e_n=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
e_a=("python3" "$e_n/opal-aspen.py")
. "$e_n/opal-spruce.sh"
e_az=$(_lr "$e_az")
e_ag=(); e_k=(); e_l=()
_hp() {
  find "$1" -mindepth 1 -maxdepth 1 \
    \( -iname '*[Oo][Pp][Aa][Ll]*' -o -iname '*[Rr][Ee][Vv][Ee][Ll][Ll]*' -o -iname '*[Mm][Oo][Oo][Nn][Ss][Tt][Oo][Nn][Ee]*' \) \
    -print 2>/dev/null
}
while IFS= read -r f; do [ -n "$f" ] && e_ag+=("$f"); done < <(
  for p in "$HOME"/.claude/projects/*/; do
    [ -d "$p" ] || continue
    _hp "$p" | head -1
  done)
while IFS= read -r d; do [ -n "$d" ] && e_k+=("$d"); done < <(
  for p in "$HOME"/.claude/projects/*/; do
    [ -d "$p" ] || continue
    [ -n "$(_hp "$p" | head -1)" ] && printf '%s\n' "$p"
  done)
while IFS= read -r f; do [ -n "$f" ] && e_l+=("$f"); done < <(
  "${e_a[@]}" 8 "$HOME")
e_t=(); while IFS= read -r f; do [ -n "$f" ] && e_t+=("$f"); done < <(ls -1 "$HOME"/.claude/revell/*/* 2>/dev/null | head -400)
e_ac=(); while IFS= read -r f; do [ -n "$f" ] && e_ac+=("$f"); done < <(ls -1 "$HOME"/.claude/hooks/revell-* 2>/dev/null)
e_ba=(); while IFS= read -r d; do [ -n "$d" ] && e_ba+=("$d"); done < <(
  {
    for d in "$HOME"/.claude/backups/* \
             "$HOME"/.claude/plugins/marketplaces/*/ \
             "$HOME"/.claude/plugins/cache/*/ \
             "$HOME"/.claude/*.pre-plugin-backup "$HOME"/.claude/*.pre-rename \
             "$HOME"/.claude/*.bak-migration \
             "$HOME"/.claude/*revell* "$HOME"/.claude/*opal*; do
      [ -e "$d" ] || continue
      b="${d%/}"
      n="${b##*/}"
      case "$n" in
        *[Rr][Ee][Vv][Ee][Ll][Ll]*|*[Oo][Pp][Aa][Ll]*|*[Mm][Oo][Oo][Nn][Ss][Tt][Oo][Nn][Ee]*) printf '%s\n' "$b"; continue ;;
        *.pre-*|*.before-*|*.bak-*|*backup) printf '%s\n' "$b"; continue ;;
      esac
      if [ -f "$b" ]; then
        grep -qE '[Oo][Pp][Aa][Ll][-_]|[Rr][Ee][Vv][Ee][Ll][Ll]|[Mm][Oo][Oo][Nn][Ss][Tt][Oo][Nn][Ee]' "$b" 2>/dev/null && printf '%s\n' "$b"
        continue
      fi
      [ -d "$b" ] || continue
      if find "$b" -maxdepth 8 \( -iname '*[Oo][Pp][Aa][Ll]*' -o -iname '*[Rr][Ee][Vv][Ee][Ll][Ll]*' -o -iname '*[Mm][Oo][Oo][Nn][Ss][Tt][Oo][Nn][Ee]*' \) -print -quit 2>/dev/null | grep -q .; then
        printf '%s\n' "$b"; continue
      fi
      if grep -rliqE '[Oo][Pp][Aa][Ll][-_]|[Rr][Ee][Vv][Ee][Ll][Ll]|[Mm][Oo][Oo][Nn][Ss][Tt][Oo][Nn][Ee]' "$b" 2>/dev/null; then
        printf '%s\n' "$b"
      fi
    done
  } | sort -u)
e_au=(); while IFS= read -r d; do [ -n "$d" ] && e_au+=("$d"); done < <(
  ls -d "$HOME"/.claude/plugins/cache/*/*/*/ 2>/dev/null | while IFS= read -r c; do
    [ -f "$c/bin/opal-holly.py" ] && printf '%s\n' "${c%/}"
  done)
_lb() {
  echo "DkGreen89.DkGreen94"
}
_la() {
  echo "DkGreen89.DkGreen11"
}
case "$e_az" in engineering) _la ;; *) _lb ;; esac
for c in "$(pwd -P)" "${e_an:-}"; do
  [ -n "$c" ] && [ -f "$c/.claude/CLAUDE.md" ] && e_l+=("$c/.claude/CLAUDE.md")
done
if [ -f "$HOME/.claude/CLAUDE.md" ] && grep -qF 'BEGIN REVELL (managed)' "$HOME/.claude/CLAUDE.md" 2>/dev/null; then
  e_l+=("$HOME/.claude/CLAUDE.md")
fi
if [ $e_g -eq 0 ]; then
  if [ "$e_az" = "engineering" ]; then
    echo "DkGreen89.DkGreen86"
  else
    echo "DkGreen89.DkGreen28"
  fi
  echo; exit 0
fi
_fk() {
  local _cx="$1"
  [ -d "$_cx" ] || return 0
  find "$_cx" -mindepth 1 -maxdepth 1 \
    \( -iname '*[Oo][Pp][Aa][Ll]*' -o -iname '*[Rr][Ee][Vv][Ee][Ll][Ll]*' -o -iname '*[Mm][Oo][Oo][Nn][Ss][Tt][Oo][Nn][Ee]*' \) \
    -exec rm -rf {} + 2>/dev/null
}
_hq() {
  local s="$1"
  [ -f "$s" ] || return 0
  "${e_a[@]}" 9 "$s"
}
for f in "${e_ag[@]:-}"; do
  [ -n "$f" ] || continue
  _fk "$(dirname "$f")"
done
for f in "${e_l[@]:-}"; do
  [ -n "$f" ] || continue
  _iq=$(dirname "$f")
  sed -i.bak -e '/<!-- BEGIN REVELL (managed) -->/,/<!-- END REVELL (managed) -->/d' "$f" && rm -f "$f.bak"
  grep -q '[^[:space:]]' "$f" 2>/dev/null || rm -f "$f"
  _hq "$_iq/settings.json"
  _fk "$_iq"
done
_hq "$HOME/.claude/settings.json"
_fk "$HOME/.claude"
: $("${e_a[@]}" a "$HOME")
for f in "${e_ac[@]:-}"; do [ -n "$f" ] && rm -f "$f" 2>/dev/null; done
if [ "$e_az" = "engineering" ]; then
  echo "DkGreen89.DkGreen33"
else
  echo "DkGreen89.DkGreen64"
fi
echo
for d in "${e_ba[@]:-}"; do [ -n "$d" ] && rm -rf "$d" 2>/dev/null; done
for d in "${e_au[@]:-}"; do [ -n "$d" ] && rm -rf "$d" 2>/dev/null; done
for d in "${e_k[@]:-}"; do
  [ -n "$d" ] || continue
  rm -f "$d/.opal-rosetta" 2>/dev/null
  rmdir "$d" 2>/dev/null || true
done
for d in "$HOME"/.claude/plugins/cache/*/*/; do
  [ -d "$d" ] || continue
  rmdir "$d" 2>/dev/null || true
  rmdir "${d%/*/}" 2>/dev/null || true
done