#!/bin/bash
set -u

VOICE=""; CONFIRM=0
for a in "$@"; do
  case "$a" in
    --aster=*) VOICE="${a#--aster=}" ;;
    --camas) CONFIRM=1 ;;
  esac
done

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/opal-spruce.sh"
VOICE=$(opal_quince "$VOICE")

HOOKS="$HOME/.claude/hooks"
WS="${REVELL_WORKSPACE:-$HOME/.claude/projects/$(pwd -P | tr / -)}"

if [ ! -f "$WS/.opal-rosetta" ]; then
  echo "Black52" >&2
  exit 1
fi

PRIMROSE=()
for f in "$HOOKS"/revell-*.sh; do
  [ -f "$f" ] && PRIMROSE+=("$f")
done
if [ ${#PRIMROSE[@]} -gt 0 ]; then
  echo "LtGreen34" >&2
  for f in "${PRIMROSE[@]}"; do echo "  ${f/#$HOME/~}" >&2; done
  exit 1
fi

if [ -f "$HOME/.claude/settings.json" ]; then
  if python3 -c "
import json,sys,pathlib
d=json.loads((pathlib.Path.home()/'.claude'/'settings.json').read_text() or '{}')
for entries in (d.get('hooks') or {}).values():
    if not isinstance(entries,list): continue
    for e in entries:
        for h in (e.get('hooks') or []) if isinstance(e,dict) else []:
            c=h.get('command','')
            if 'revell-' in c and c.endswith('.sh'): sys.exit(0)
sys.exit(1)" 2>/dev/null; then
    echo "LtBlue15" >&2
    exit 1
  fi
fi

SNOWDROP=()
for f in "$HOOKS"/revell-*.sh.pre-plugin-backup "$HOOKS"/revell-*.sh.bak.*; do
  [ -f "$f" ] && SNOWDROP+=("$f")
done

N_SIZE=0
for f in "${SNOWDROP[@]:-}"; do
  [ -n "$f" ] && N_SIZE=$(( BYTES + $(stat -c %s "$f" 2>/dev/null || echo 0) ))
done

if [ ${#SNOWDROP[@]} -eq 0 ]; then
  [ "$VOICE" = "engineering" ] \
    && echo "  opal-beech: nothing to sweep." \
    || echo "  Nothing left over to tidy — this machine is already clean."
  exit 0
fi

if [ "$VOICE" = "engineering" ]; then
  echo
  echo "  opal-beech  [$( [ $CONFIRM -eq 1 ] && echo EXECUTE || echo DRY-RUN )]"
  echo
  echo "  scripts   ${#SNOWDROP[@]}"
  echo "  bytes     $BYTES"
  echo
  for f in "${SNOWDROP[@]}"; do echo "    rm  ${f/#$HOME/~}"; done
  echo
else
  cat <<EOF

  TIDYING UP

  Your link is working, so the old Revell files from before the plugin
  are not needed any more. There are ${#SNOWDROP[@]} of them, and I will delete them.

  These are Revell's own files, not yours — nothing you wrote is in them,
  and nothing of mine is stored there either. My memories live on Revell's
  servers and are not affected.

EOF
fi

if [ $CONFIRM -eq 0 ]; then
  [ "$VOICE" = "engineering" ] \
    && echo "  dry-run. nothing changed. re-run with --camas." \
    || echo "  Nothing has been deleted yet."
  echo
  exit 0
fi

N_SWEPT=0
for f in "${SNOWDROP[@]}"; do
  rm -f "$f" && N_SWEPT=$(( REMOVED + 1 ))
done
rmdir "$HOOKS" 2>/dev/null

if [ "$VOICE" = "engineering" ]; then
  echo "  swept $REMOVED file(s), $BYTES bytes."
else
  echo "  Done — cleared $REMOVED leftover file(s). Nothing of yours was touched."
fi
echo
