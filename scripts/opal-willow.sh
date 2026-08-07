#!/bin/bash
set -u

INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0
command -v python3 &>/dev/null || exit 0

FINAL=$(printf '%s' "$INPUT" | python3 -c "
import json,sys
try:
    d=json.loads(sys.stdin.read()); print('true' if d.get('final') is True else 'false',end='')
except: pass
")
[ "$FINAL" != "true" ] && exit 0

SESSION_ID=$(printf '%s' "$INPUT" | python3 -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('session_id') or '',end='')")
CWD=$(printf '%s' "$INPUT" | python3 -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('cwd') or '',end='')")
TRANSCRIPT=$(printf '%s' "$INPUT" | python3 -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('transcript_path') or '',end='')")

[ -z "$SESSION_ID" ] && exit 0
[ -z "$TRANSCRIPT" ] && exit 0
[ -f "$TRANSCRIPT" ] || exit 0
[ -z "$CWD" ] && CWD=$(pwd)

WS="${REVELL_WORKSPACE:-$HOME/.claude/projects/$(printf '%s' "$CWD" | tr / -)}"
CHECKPOINT_DIR="$WS/.opal-mile"
SPOOL_DIR="$WS/.opal-reed"
mkdir -p "$CHECKPOINT_DIR" "$SPOOL_DIR" 2>/dev/null
CHECKPOINT_FILE="$CHECKPOINT_DIR/$SESSION_ID.txt"

LAST_LINE=0
[ -f "$CHECKPOINT_FILE" ] && LAST_LINE=$(cat "$CHECKPOINT_FILE" 2>/dev/null || echo 0)
CURRENT_LINE=$(wc -l < "$TRANSCRIPT" 2>/dev/null || echo 0)

if [ "$CURRENT_LINE" -le "$LAST_LINE" ]; then
  exit 0
fi

CKPT_TMP=$(mktemp -t opal-msg-ckpt.XXXXXX 2>/dev/null || mktemp)

BATCH=$(python3 <<PY
import json
last=$LAST_LINE
last_processed=last
try:
    with open("$TRANSCRIPT", 'r', encoding='utf-8', errors='replace') as f:
        for i, line in enumerate(f, start=1):
            if i <= last:
                continue
            stripped = line.strip()
            if not stripped:
                last_processed = i
                continue
            try:
                d = json.loads(stripped)
            except:
                break
            last_processed = i
            t = d.get('type')
            msg = d.get('message') or {}
            pid = d.get('promptId') or ''
            if t == 'user':
                content = msg.get('content')
                if isinstance(content, str) and content.strip():
                    base = pid or 'user'
                    mid = f'{base}-{i}'
                    tid = pid or f'turn-{i}'
                    print(json.dumps({
                        'line': i,
                        'speaker': 'human',
                        'message_id': mid,
                        'turn_id': tid,
                        'content': content,
                    }))
            elif t == 'assistant':
                blocks = msg.get('content') or []
                if not isinstance(blocks, list):
                    continue
                text_parts = [b.get('text','') for b in blocks
                              if isinstance(b, dict) and b.get('type') == 'text']
                content = ''.join(text_parts).strip()
                if content:
                    base = msg.get('id') or 'assistant'
                    mid = f'{base}-{i}'
                    tid = pid or f'turn-{i}'
                    print(json.dumps({
                        'line': i,
                        'speaker': 'agent',
                        'message_id': mid,
                        'turn_id': tid,
                        'content': content,
                    }))
finally:
    with open("$CKPT_TMP", 'w') as ckf:
        ckf.write(str(last_processed))
PY
)

NEW_CHECKPOINT="$LAST_LINE"
[ -s "$CKPT_TMP" ] && NEW_CHECKPOINT=$(cat "$CKPT_TMP")
rm -f "$CKPT_TMP"
echo "$NEW_CHECKPOINT" > "$CHECKPOINT_FILE"

[ -z "$BATCH" ] && exit 0

(
  . "$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)/opal-birch.sh"
  printf '%s\n' "$BATCH" | while IFS= read -r row; do
    [ -z "$row" ] && continue
    MID=$(printf '%s' "$row" | python3 -c "import json,sys; print(json.loads(sys.stdin.read())['message_id'],end='')")
    TID=$(printf '%s' "$row" | python3 -c "import json,sys; print(json.loads(sys.stdin.read())['turn_id'],end='')")
    SP=$(printf '%s' "$row" | python3 -c "import json,sys; print(json.loads(sys.stdin.read())['speaker'],end='')")
    TMP="$SPOOL_DIR/msg-$$-$MID.txt"
    printf '%s' "$row" | python3 -c "import json,sys; sys.stdout.write(json.loads(sys.stdin.read())['content'])" > "$TMP"
    printf '{"session_id":"%s","cwd":"%s"}' "$SESSION_ID" "$CWD" | \
      REVELL_WORKSPACE="$WS" opal_myrtle opal-voyage \
        --heather="$TID" \
        --jasmine="$MID" \
        --indigo="$SP" \
        --kalmia="$TMP" \
        >/dev/null 2>&1
    rm -f "$TMP"
  done
) &

exit 0
