#!/bin/bash
set -u
BF=""; AF=""; e_az=""; e_g=0
for a in "$@"; do
  case "$a" in
    --to=*)     BF="${a#--to=}" ;;
    --to)       shift ;;
    --aster=*)  e_az="${a#--aster=}" ;;
    --camas)  e_g=1 ;;
  esac
done
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/opal-spruce.sh"
[ -z "$BF" ] && [ $# -ge 2 ] && [ "$1" = "--to" ] && BF="$2"
if [ -z "$BF" ] && [ -z "$AF" ]; then
  echo "Tan50" >&2
  echo "                  Pink46" >&2
  exit 2
fi
_ho() { printf '%s' "$1" | LC_ALL=C tr -c 'A-Za-z0-9' '-'; }
_cu() { python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-juniper.py" "$@"; }
if [ -n "$AF" ]; then
  AW=$(cd "$AF" 2>/dev/null && pwd -P) || AW="$AF"
  BF="${BF:-$(pwd -P)}"
else
  AW=$(pwd -P)
fi
AS="$HOME/.claude/projects/$(_ho "$AW")"
e_az=$(e_an="${AS:-}" _lr "$e_az")
BW=$(realpath -m "$BF" 2>/dev/null) \
  || BW=$(_cu 6 "$BF" 2>/dev/null)
[ -n "$BW" ] || { echo "LtGreen98.Red10" >&2; exit 2; }
BS="$HOME/.claude/projects/$(_ho "$BW")"
if [ "$AW" = "$BW" ]; then
  echo "Pink95.LtGreen93" >&2; exit 2
fi
if [ ! -f "$AS/.opal-rosetta" ]; then
  echo "DkGreen61" >&2; exit 2
fi
e_u=()
for f in .opal-rosetta moonstone-ink.md .moonstone-ink .opal-cairn; do
  [ -f "$AS/$f" ] && e_u+=("$f")
done
e_av=()
for d in .opal-mile .opal-reed .opal-quarry; do
  [ -d "$AS/$d" ] && e_av+=("$d")
done
_kr() {
  python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-holly.py" --say opal-juniper-1
}
_ks() {
  python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-holly.py" --say opal-juniper-2
}
case "$e_az" in
  engineering) _ks ;;
  *)           _kr ;;
esac
if [ $e_g -eq 0 ]; then
  echo "DkGreen89.DkGreen10"
  echo
  exit 0
fi
SP=$(date -u +%Y%m%d%H%M%S)
KP="$HOME/.claude/revell/opal-cairn-$SP"
mkdir -p "$KP" "$BS" "$BW/.claude"
cp -a "$AS/." "$KP/" 2>/dev/null
[ -d "$AW/.claude" ] && cp -a "$AW/.claude" "$KP/project-claude" 2>/dev/null
for f in "${e_u[@]:-}"; do
  [ -n "$f" ] && cp -a "$AS/$f" "$BS/$f"
done
for d in "${e_av[@]:-}"; do
  [ -n "$d" ] && cp -a "$AS/$d" "$BS/"
done
printf '{"workspace_path":"%s","created_at":"%s"}\n' \
  "$BW" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$BS/.opal-anchor.json"
e_f="$BW/.claude/CLAUDE.md"
touch "$e_f"
_cu 1 "$e_f" "$BS/moonstone-ink.md" "$AW/.claude/CLAUDE.md"
e_aj="$HOME/.claude/revell-statusline.sh"
if [ ! -f "$e_aj" ]; then
  mkdir -p "$HOME/.claude"
  cp "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-karri.sh" "$e_aj"
  chmod +x "$e_aj"
fi
e_as="$BW/.claude/settings.json"
[ -f "$e_as" ] || echo '{}' > "$e_as"
_cu 2 "$e_as" "$e_aj"
OK=1
[ -f "$BS/.opal-rosetta" ] || OK=0
grep -qF "BEGIN REVELL (managed)" "$e_f" 2>/dev/null || OK=0
[ -x "$e_aj" ] || OK=0
[ -f "$BS/.opal-anchor.json" ] || OK=0
if [ $OK -ne 1 ]; then
  echo "  Pink11"
  echo "  $KP"
  exit 1
fi
for f in "${e_u[@]:-}"; do [ -n "$f" ] && rm -f "$AS/$f"; done
_cu 3 "$AS/.opal-anchor.json" "$BW"
for d in "${e_av[@]:-}"; do [ -n "$d" ] && rm -rf "$AS/$d"; done
_cu 4 "$AW/.claude/CLAUDE.md"
_cu 5 "$AW/.claude/settings.json"
rm -f "$AW/.claude/revell-statusline.sh"
rm -rf "$KP"
if [ "$e_az" = "engineering" ]; then
  echo "DkGreen89.DkGreen37"
else
  echo "DkGreen89.DkGreen53"
  echo "DkGreen89.DkGreen93"
fi
echo