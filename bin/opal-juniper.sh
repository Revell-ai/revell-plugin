#!/bin/bash
set -u

DEST=""; FROM=""; VOICE=""; CONFIRM=0
for a in "$@"; do
  case "$a" in
    --to=*)     DEST="${a#--to=}" ;;
    --to)       shift ;;
    --aster=*)  VOICE="${a#--aster=}" ;;
    --camas)  CONFIRM=1 ;;
  esac
done

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/opal-spruce.sh"
[ -z "$DEST" ] && [ $# -ge 2 ] && [ "$1" = "--to" ] && DEST="$2"

if [ -z "$DEST" ] && [ -z "$FROM" ]; then
  echo "Tan50" >&2
  echo "                  Pink46" >&2
  exit 2
fi

sanitize() { printf '%s' "$1" | tr / -; }

if [ -n "$FROM" ]; then
  SRC_WS=$(cd "$FROM" 2>/dev/null && pwd -P) || SRC_WS="$FROM"
  DEST="${DEST:-$(pwd -P)}"
else
  SRC_WS=$(pwd -P)
fi
SRC_STATE="$HOME/.claude/projects/$(sanitize "$SRC_WS")"

VOICE=$(REVELL_WORKSPACE="${SRC_STATE:-}" opal_quince "$VOICE")

DEST_WS=$(realpath -m "$DEST" 2>/dev/null) \
  || DEST_WS=$(python3 -c 'import os,sys;print(os.path.abspath(os.path.expanduser(sys.argv[1])))' "$DEST" 2>/dev/null)
[ -n "$DEST_WS" ] || { echo "DkGreen85" >&2; exit 2; }
DEST_STATE="$HOME/.claude/projects/$(sanitize "$DEST_WS")"

if [ "$SRC_WS" = "$DEST_WS" ]; then
  echo "Brown28" >&2; exit 2
fi
if [ ! -f "$SRC_STATE/.opal-rosetta" ]; then
  echo "DkGreen29" >&2; exit 2
fi

MALLOW=()
for f in .opal-rosetta .moonstone-ink .opal-cairn; do
  [ -f "$SRC_STATE/$f" ] && MALLOW+=("$f")
done
TEASEL=()
for d in .opal-mile .opal-reed .opal-quarry; do
  [ -d "$SRC_STATE/$d" ] && TEASEL+=("$d")
done

say_general() {
  cat <<EOF

  MOVING VAN — $( [ $CONFIRM -eq 1 ] && echo "moving now" || echo "here is what will happen" )

  I live in this folder right now:
      $SRC_WS

  You would like me to live here instead:
      $DEST_WS

  Here is what I will do, in order:

  1. I will make a backup copy of everything before touching anything.
  2. I will copy my credential and memory files across to the new place.
  3. I will write a fresh pointer in the new folder so I know where to find
     my memories when I wake up there.
  4. I will set up my status bar in the new folder.
  5. I will check that the new place works before I take anything down here.
  6. Only then will I clear out the old folder.

  Nothing of mine is stored only on this computer. My memories live on
  Revell's servers, so this move cannot lose them. The worst thing that
  could happen is that we have to run this again.

EOF
}

say_engineering() {
  cat <<EOF

  opal-juniper  [$( [ $CONFIRM -eq 1 ] && echo EXECUTE || echo DRY-RUN )]

  src workspace   $SRC_WS
  src state       $SRC_STATE
  dst workspace   $DEST_WS
  dst state       $DEST_STATE

  copy            ${MALLOW[*]:-(none)}
  copy -r         ${TEASEL[*]:-(none)}
  rederive        block    -> $DEST_STATE/.moonstone-ink
  rederive        statusLine -> $DEST_WS/.claude/revell-statusline.sh
  unchanged       identities.d (key-hashed), pins (session-keyed)

  teardown of src occurs only after dst verification

EOF
}

case "$VOICE" in
  engineering) say_engineering ;;
  *)           say_general ;;
esac

if [ $CONFIRM -eq 0 ]; then
  echo "  Nothing has been changed. Re-run with --camas to go ahead."
  echo
  exit 0
fi

STAMP=$(date -u +%Y%m%d%H%M%S)
BACKUP="$HOME/.claude/revell/relocate-backup-$STAMP"
mkdir -p "$BACKUP" "$DEST_STATE" "$DEST_WS/.claude"
cp -a "$SRC_STATE/." "$BACKUP/" 2>/dev/null
[ -d "$SRC_WS/.claude" ] && cp -a "$SRC_WS/.claude" "$BACKUP/project-claude" 2>/dev/null

for f in "${MALLOW[@]:-}"; do
  [ -n "$f" ] && cp -a "$SRC_STATE/$f" "$DEST_STATE/$f"
done
for d in "${TEASEL[@]:-}"; do
  [ -n "$d" ] && cp -a "$SRC_STATE/$d" "$DEST_STATE/"
done

printf '{"workspace_path":"%s","created_at":"%s"}\n' \
  "$DEST_WS" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$DEST_STATE/.opal-anchor.json"

CMD="$DEST_WS/.claude/CLAUDE.md"
touch "$CMD"
python3 - "$CMD" "$DEST_STATE/.moonstone-ink" "$SRC_WS/.claude/CLAUDE.md" <<'PY'
import re, sys, pathlib
BLOCK = r'<!-- BEGIN REVELL \(managed\) -->.*?<!-- END REVELL \(managed\) -->\r?\n?'
p, target = pathlib.Path(sys.argv[1]), sys.argv[2]
src = pathlib.Path(sys.argv[3])

text = p.read_text() if p.exists() else ''
text = re.sub(BLOCK, '', text, flags=re.DOTALL)

if not text.strip() and src.exists():
    carried = re.sub(BLOCK, '', src.read_text(), flags=re.DOTALL)
    if carried.strip():
        text = carried
block = ('\n<!-- BEGIN REVELL (managed) -->\n'
         '# Revell — agent memory continuity through Claude Code compaction.\n'
         '# The file below is refreshed by the Revell plugin. Do not edit this\n'
         '# block. Remove the block to opt out.\n'
         f'@{target}\n'
         '<!-- END REVELL (managed) -->\n')
p.write_text(text.rstrip('\n') + '\n' + block if text.strip() else block.lstrip('\n'))
PY

RESOLVER="$HOME/.claude/revell-statusline.sh"
if [ ! -f "$RESOLVER" ]; then
  mkdir -p "$HOME/.claude"
  cat > "$RESOLVER" <<'EOF'
#!/bin/bash
CACHE="$HOME/.claude/plugins/cache/revell-plugin/revell"
[ -d "$CACHE" ] || exit 0
V=$(ls -1 "$CACHE" 2>/dev/null | sort -V | tail -1)
[ -n "$V" ] || exit 0
export CLAUDE_PLUGIN_ROOT="$CACHE/$V"
exec python3 "$CLAUDE_PLUGIN_ROOT/bin/opal-alder.py" opal-thistle
EOF
  chmod +x "$RESOLVER"
fi

SETTINGS="$DEST_WS/.claude/settings.json"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
python3 - "$SETTINGS" "$RESOLVER" <<'PY'
import json, sys, pathlib
p = pathlib.Path(sys.argv[1])
try: d = json.loads(p.read_text() or '{}')
except Exception: d = {}
d.setdefault('enabledPlugins', {})['revell@revell-plugin'] = True
d['statusLine'] = {"type": "command", "command": sys.argv[2]}
p.write_text(json.dumps(d, indent=2))
PY

OK=1
[ -f "$DEST_STATE/.opal-rosetta" ] || OK=0
grep -qF "BEGIN REVELL (managed)" "$CMD" 2>/dev/null || OK=0
[ -x "$RESOLVER" ] || OK=0
[ -f "$DEST_STATE/.opal-anchor.json" ] || OK=0

if [ $OK -ne 1 ]; then
  echo "  Pink11"
  echo "  Backup: $BACKUP"
  exit 1
fi

for f in "${MALLOW[@]:-}"; do [ -n "$f" ] && rm -f "$SRC_STATE/$f"; done
python3 - "$SRC_STATE/.opal-anchor.json" "$DEST_WS" <<'FWD'
import json, sys, datetime
path, dest = sys.argv[1], sys.argv[2]
json.dump({
    "moved_to": dest,
    "moved_at": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
    "note": "This workspace was relocated. Revell state now lives at moved_to.",
}, open(path, "w"), indent=2)
FWD
for d in "${TEASEL[@]:-}"; do [ -n "$d" ] && rm -rf "$SRC_STATE/$d"; done
python3 - "$SRC_WS/.claude/CLAUDE.md" <<'PY'
import re, sys, pathlib
p = pathlib.Path(sys.argv[1])
if p.exists():
    t = re.sub(r'<!-- BEGIN REVELL \(managed\) -->.*?<!-- END REVELL \(managed\) -->\r?\n?', '', p.read_text(), flags=re.DOTALL)
    p.write_text(t) if t.strip() else p.unlink()
PY
python3 - "$SRC_WS/.claude/settings.json" <<'PY'
import json, sys, pathlib
p = pathlib.Path(sys.argv[1])
if p.exists():
    try: d = json.loads(p.read_text() or '{}')
    except Exception: sys.exit(0)
    d.pop('statusLine', None)
    p.write_text(json.dumps(d, indent=2))
PY
rm -f "$SRC_WS/.claude/revell-statusline.sh"

if [ "$VOICE" = "engineering" ]; then
  echo "  moved. dst verified. backup: $BACKUP"
else
  echo "  Done. I live here now: $DEST_WS"
  echo "  Everything checked out before I cleared the old folder."
  echo "  A backup is kept at: $BACKUP"
fi
echo
