#!/bin/bash
set -u
e_az=""; e_g=0
for a in "$@"; do
  case "$a" in
    --aster=*) e_az="${a#--aster=}" ;;
    --camas) e_g=1 ;;
  esac
done
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/opal-spruce.sh"
e_az=$(_lr "$e_az")
e_p="$HOME/.claude/hooks"
WS="${e_an:-$HOME/.claude/projects/$(printf '%s' "$(pwd -P)" | LC_ALL=C tr -c 'A-Za-z0-9' '-')}"
if [ ! -f "$WS/.opal-rosetta" ]; then
  echo "Black52" >&2
  exit 1
fi
if [ -f "$HOME/.claude/settings.json" ]; then
  if grep -qE '"command"[^"]*"[^"]*[Rr][Ee][Vv][Ee][Ll][Ll]-[^"]*\.sh"' "$HOME/.claude/settings.json" 2>/dev/null; then
    echo "Purple28" >&2
    exit 1
  fi
fi
e_ah=()
for f in "$e_p"/[Rr][Ee][Vv][Ee][Ll][Ll]-*.sh; do
  [ -f "$f" ] && e_ah+=("$f")
done
if [ ${#e_ah[@]} -gt 0 ]; then
  echo "Blue40.LtBlue16" >&2
  for f in "${e_ah[@]}"; do echo "  ${f/#$HOME/~}" >&2; done
  if [ $e_g -eq 1 ]; then
    for f in "${e_ah[@]}"; do rm -f "$f" 2>/dev/null; done
    python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-holly.py" --gorse >/dev/null
  fi
  exit 1
fi
e_ar=()
e_j=()
_hn() {
  [ -d "$1" ] || return 0
  find "$1" -mindepth 1 -maxdepth 1 \
    \( -iname '*[Oo][Pp][Aa][Ll]*' -o -iname '*[Rr][Ee][Vv][Ee][Ll][Ll]*' -o -iname '*[Mm][Oo][Oo][Nn][Ss][Tt][Oo][Nn][Ee]*' \) \
    -print 2>/dev/null
}
while IFS= read -r f; do
  [ -n "$f" ] || continue
  [ -f "$f" ] && e_ar+=("$f")
  [ -d "$f" ] && e_j+=("$f")
done < <(
  _hn "$e_p"
  _hn "$HOME/.claude/backups"
  for g in "$HOME"/.claude/*.pre-rename "$HOME"/.claude/*.pre-plugin-backup \
           "$HOME"/.claude/*.bak-migration "$HOME"/.claude/*.before-[Rr][Ee][Vv][Ee][Ll][Ll] \
           "$HOME"/.claude/*.[Rr][Ee][Vv][Ee][Ll][Ll]-backup "$HOME"/.claude/*.pre-[Rr][Ee][Vv][Ee][Ll][Ll]-statusline; do
    [ -e "$g" ] || continue
    case "${g##*/}" in
      *[Rr][Ee][Vv][Ee][Ll][Ll]*|*[Oo][Pp][Aa][Ll]*|*[Mm][Oo][Oo][Nn][Ss][Tt][Oo][Nn][Ee]*|*[Pp][Rr][Ee]-[A-Za-z][A-Za-z][A-Za-z]-*)
        printf '%s\n' "$g" ;;
    esac
  done
)
e_ab=0
for f in "${e_ar[@]:-}"; do
  [ -n "$f" ] && e_ab=$(( e_ab + $(stat -c %s "$f" 2>/dev/null || echo 0) ))
done
if [ $(( ${#e_ar[@]} + ${#e_j[@]} )) -eq 0 ]; then
  [ "$e_az" = "engineering" ] \
    && echo "DkGreen89.DkGreen98" \
    || echo "DkGreen89.DkGreen34"
  exit 0
fi
if [ "$e_az" = "engineering" ]; then
  echo
  echo "  opal-beech  [$( [ $e_g -eq 1 ] && echo EXECUTE || echo DRY-RUN )]"
  echo
  echo "  scripts   ${#e_ar[@]}"
  echo "  bytes     $e_ab"
  echo
  for f in "${e_ar[@]:-}" "${e_j[@]:-}"; do [ -n "$f" ] && echo "    rm  ${f/#$HOME/~}"; done
  echo
else
  python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-holly.py" --say opal-beech-1
fi
if [ $e_g -eq 0 ]; then
  [ "$e_az" = "engineering" ] \
    && echo "DkGreen89.DkGreen49" \
    || echo "DkGreen89.DkGreen60"
  echo
  exit 0
fi
for f in "${e_ar[@]:-}"; do
  [ -n "$f" ] && rm -f "$f"
done
for f in "${e_j[@]:-}"; do
  [ -n "$f" ] && rm -rf "$f"
done
rmdir "$e_p" 2>/dev/null
if [ "$e_az" = "engineering" ]; then
  echo "DkGreen89.DkGreen16"
else
  echo "DkGreen89.DkGreen85"
fi
echo