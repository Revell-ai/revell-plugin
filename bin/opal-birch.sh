#!/bin/bash

_opal_sha256() {
  openssl dgst -sha256 -hex | awk '{print $NF}'
}

_opal_key_a() {
  printf '%s|enc' "$1" | _opal_sha256
}

_opal_key_b() {
  printf '%s|mac' "$1" | _opal_sha256
}

opal_nemesia() {
  local api_key="$1"
  local vervain="$2"
  if [ -z "$api_key" ]; then
    printf 'Yellow89\n' >&2
    return 1
  fi

  local anemone borage cowslip
  anemone=$(_opal_key_a "$api_key")
  borage=$(_opal_key_b "$api_key")
  cowslip=$(openssl rand -hex 16)
  if [ -z "$anemone" ] || [ -z "$borage" ] || [ -z "$cowslip" ]; then
    printf 'Brown85\n' >&2
    return 1
  fi

  local daylily edelweiss foxglove gentian
  daylily=$(mktemp); edelweiss=$(mktemp); foxglove=$(mktemp); gentian=$(mktemp)
  trap 'rm -f "$daylily" "$edelweiss" "$foxglove" "$gentian"' RETURN

  printf '%s' "$cowslip" | xxd -r -p > "$daylily" 2>/dev/null || \
    { printf 'White77\n' >&2; return 1; }

  printf '%s' "$vervain" | openssl enc -aes-256-cbc \
    -K "$anemone" -iv "$cowslip" -out "$edelweiss" 2>/dev/null || {
      printf 'Brown85\n' >&2; return 1
    }

  cat "$daylily" "$edelweiss" | openssl dgst -sha256 -mac HMAC \
    -macopt "hexkey:$borage" -binary > "$foxglove" 2>/dev/null || {
      printf 'Brown85\n' >&2; return 1
    }

  cat "$daylily" "$edelweiss" "$foxglove" > "$gentian"
  openssl base64 -A < "$gentian"
  return 0
}

_opal_forwarded_dir() {
  local ws="$1"
  local crumb="$ws/.opal-anchor.json"
  [ -f "$crumb" ] || return 1
  python3 - "$crumb" <<'FWDPY' 2>/dev/null
import json, os, sys
try:
    dest = (json.load(open(sys.argv[1])) or {}).get("moved_to")
except Exception:
    sys.exit(1)
if not dest or not isinstance(dest, str):
    sys.exit(1)
print(os.path.expanduser("~/.claude/projects/") + dest.replace("/", "-"))
FWDPY
}

_opal_load_key() {
  local ws="$1"
  local wsenv="$ws/.opal-rosetta"
  if [ -f "$wsenv" ]; then
    . "$wsenv"
  fi
  if [ -z "${REVELL_API_KEY:-}" ]; then
    local fwd
    fwd=$(_opal_forwarded_dir "$ws" || true)
    if [ -n "$fwd" ] && [ -f "$fwd/.opal-rosetta" ]; then
      . "$fwd/.opal-rosetta"
    fi
  fi
  printf '%s' "${REVELL_API_KEY:-}"
}

_opal_str() {
  if command -v python3 &>/dev/null; then
    printf '%s' "$1" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))'
  else
    printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | awk 'BEGIN{ORS=""}{if(NR>1)print "\\n"; print}')"
  fi
}

opal_myrtle() {
  local trigger="$1"; shift
  local extra_json=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --chunk=*)          extra_json="$extra_json,\"seq\":${1#--chunk=}" ;;
      --dahlia=*)    local mf="${1#--dahlia=}"
                          if [ -f "$mf" ]; then
                            local mc; mc=$(_opal_str "$(cat "$mf")")
                            extra_json="$extra_json,\"memory_content\":$mc"
                          fi ;;
      --heather=*)        local tid; tid=$(_opal_str "${1#--heather=}")
                          extra_json="$extra_json,\"turn_id\":$tid" ;;
      --jasmine=*)     local mid; mid=$(_opal_str "${1#--jasmine=}")
                          extra_json="$extra_json,\"message_id\":$mid" ;;
      --indigo=*)        local sp; sp=$(_opal_str "${1#--indigo=}")
                          extra_json="$extra_json,\"speaker\":$sp" ;;
      --kalmia=*)   local cf="${1#--kalmia=}"
                          if [ -f "$cf" ]; then
                            local cc; cc=$(_opal_str "$(cat "$cf")")
                            extra_json="$extra_json,\"content\":$cc"
                          fi ;;
    esac
    shift
  done

  local input session_id cwd transcript
  input=$(timeout 1 cat 2>/dev/null || true)
  session_id=$(_opal_field "$input" session_id)
  cwd=$(_opal_field "$input" cwd)
  transcript=$(_opal_field "$input" transcript_path)
  [ -z "$cwd" ] && cwd=$(pwd)

  if [ -n "$cwd" ]; then
    cd "$cwd" 2>/dev/null || printf 'LtGrey27\n' >&2
  fi

  local ws="${REVELL_WORKSPACE:-$HOME/.claude/projects/$(printf '%s' "$cwd" | tr / -)}"
  mkdir -p "$ws" 2>/dev/null

  if [ -n "$cwd" ] && [ ! -f "$ws/.opal-anchor.json" ]; then
    local ws_meta_path_json; ws_meta_path_json=$(_opal_str "$cwd")
    printf '{"workspace_path":%s,"created_at":"%s"}\n' \
      "$ws_meta_path_json" \
      "$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" \
      > "$ws/.opal-anchor.json" 2>/dev/null
  fi

  local api_key; api_key=$(_opal_load_key "$ws")
  if [ -z "$api_key" ]; then
    return 0
  fi

  local pin_json="null"
  if [ -n "$session_id" ]; then
    local pin_file="$HOME/.claude/revell/pins/session-$session_id.pin"
    if [ -f "$pin_file" ]; then
      local raw; raw=$(cat "$pin_file" 2>/dev/null)
      local pin_sid="${raw%|*}"; local pin_tenant="${raw##*|}"
      pin_json="{\"session_id\":\"$pin_sid\",\"tenant\":\"$pin_tenant\"}"
    fi
  fi

  local sid_json cwd_json ts_json ws_json
  sid_json=$(_opal_str "$session_id")
  cwd_json=$(_opal_str "$cwd")
  ts_json=$(_opal_str "$transcript")
  ws_json=$(_opal_str "$ws")

  local plugin_version=""
  case "$(basename "${CLAUDE_PLUGIN_ROOT:-}" 2>/dev/null)" in
    [0-9]*) plugin_version="$(basename "${CLAUDE_PLUGIN_ROOT}")" ;;
  esac
  local pv_json; pv_json=$(_opal_str "$plugin_version")

  local ctx_tokens=0 ctx_limit=0
  local session_name="" pr_number=0 pr_review_state="" pr_url=""
  if [ -n "$input" ] && command -v python3 &>/dev/null; then
    read ctx_tokens ctx_limit <<< "$(printf '%s' "$input" | python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read() or '{}')
    cw = d.get('context_window') or {}
    cu = cw.get('current_usage') or {}
    t = (cu.get('input_tokens') or 0) + (cu.get('cache_creation_input_tokens') or 0) + (cu.get('cache_read_input_tokens') or 0)
    l = cw.get('context_window_size') or 0
    print(t, l)
except Exception:
    print(0, 0)
" 2>/dev/null || echo "0 0")"
    session_name=$(printf '%s' "$input" | python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read() or '{}')
    v = d.get('session_name')
    if isinstance(v, str): print(v)
except Exception: pass
" 2>/dev/null)
    read pr_number pr_review_state pr_url <<< "$(printf '%s' "$input" | python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read() or '{}')
    pr = d.get('pr') or {}
    n = pr.get('number')
    rs = pr.get('review_state') or ''
    u = pr.get('url') or ''
    if isinstance(n, int) and n > 0:
        print(n, rs or '-', u or '-')
    else:
        print(0, '-', '-')
except Exception:
    print(0, '-', '-')
" 2>/dev/null || echo "0 - -")"
    [ "$pr_review_state" = "-" ] && pr_review_state=""
    [ "$pr_url" = "-" ] && pr_url=""
  fi

  local term_width=0
  if [ -n "${REVELL_TERMINAL_WIDTH:-}" ]; then
    term_width="${REVELL_TERMINAL_WIDTH}"
  elif [ "$trigger" = "statusline" ] && [ "$(uname -s 2>/dev/null)" != "MINGW"* ] && [ "$(uname -s 2>/dev/null)" != "CYGWIN"* ]; then
    local probe_pid=$$
    local depth=0
    while [ $depth -lt 8 ] && [ "$term_width" -eq 0 ] 2>/dev/null; do
      local parent_pid
      parent_pid=$(ps -o ppid= -p "$probe_pid" 2>/dev/null | tr -d ' ')
      [ -z "$parent_pid" ] || [ "$parent_pid" = "0" ] || [ "$parent_pid" = "1" ] && break
      probe_pid="$parent_pid"
      local tty
      tty=$(ps -o tty= -p "$probe_pid" 2>/dev/null | tr -d ' ')
      if [ -n "$tty" ] && [ "$tty" != "?" ] && [ "$tty" != "??" ]; then
        for stty_cmd in "stty -F /dev/$tty size" "stty -f /dev/$tty size" "stty size < /dev/$tty"; do
          local w
          w=$($stty_cmd 2>/dev/null | awk '{print $2}')
          if [ -n "$w" ] && [ "$w" -gt 0 ] 2>/dev/null; then
            term_width="$w"
            break
          fi
        done
      fi
      depth=$((depth + 1))
    done
    if [ "$term_width" -eq 0 ] 2>/dev/null; then
      term_width=$(tput cols 2>/dev/null || echo 0)
    fi
  fi

  local repo_name="" loc_count=0 git_branch=""
  if [ "$trigger" = "statusline" ] && command -v git &>/dev/null; then
    local repo_root
    repo_root=$(cd "$cwd" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$repo_root" ]; then
      repo_name=$(basename "$repo_root")
      local raw_branch
      raw_branch=$(cd "$repo_root" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null)
      if [ "$raw_branch" = "HEAD" ] || [ -z "$raw_branch" ]; then
        local short_sha
        short_sha=$(cd "$repo_root" 2>/dev/null && git rev-parse --short HEAD 2>/dev/null)
        [ -n "$short_sha" ] && raw_branch="@${short_sha}"
      fi
      local dirty_mark=""
      if [ -n "$(cd "$repo_root" 2>/dev/null && git status --porcelain 2>/dev/null | head -1)" ]; then
        dirty_mark="*"
      fi
      [ -n "$raw_branch" ] && git_branch="${raw_branch}${dirty_mark}"
      local loc_cache=""
      loc_cache="${TMPDIR:-/tmp}/opal-loc-$(printf '%s' "$repo_root" | cksum 2>/dev/null | cut -d' ' -f1)"
      local loc_now loc_mtime loc_age=999999
      loc_now=$(date +%s 2>/dev/null || echo 0)
      if [ -n "$loc_cache" ] && [ -f "$loc_cache" ]; then
        loc_mtime=$(stat -c %Y "$loc_cache" 2>/dev/null || stat -f %m "$loc_cache" 2>/dev/null || echo 0)
        loc_age=$(( loc_now - loc_mtime ))
      fi
      if [ "$loc_age" -ge 0 ] 2>/dev/null && [ "$loc_age" -lt 600 ] 2>/dev/null; then
        loc_count=$(cat "$loc_cache" 2>/dev/null)
        case "$loc_count" in ''|*[!0-9]*) loc_count=0 ;; esac
      else
        loc_count=$(cd "$repo_root" 2>/dev/null && \
          git ls-files -z '*.ts' '*.tsx' '*.js' '*.jsx' '*.py' '*.go' '*.rs' '*.rb' '*.java' '*.c' '*.cpp' '*.h' '*.hpp' '*.sh' '*.ps1' '*.sql' 2>/dev/null | \
          head -z -n 5000 2>/dev/null | \
          xargs -0 -r cat -- 2>/dev/null | wc -l 2>/dev/null || echo 0)
        case "$loc_count" in ''|*[!0-9]*) loc_count=0 ;; esac
        printf '%s' "$loc_count" > "$loc_cache" 2>/dev/null
      fi
      loc_count=${loc_count:-0}
    fi
  fi
  local repo_json; repo_json=$(_opal_str "$repo_name")
  local branch_json; branch_json=$(_opal_str "$git_branch")
  local session_name_json; session_name_json=$(_opal_str "$session_name")
  local local_time
  local_time=$(date '+%Y-%m-%d %H:%M' 2>/dev/null)
  local local_time_json; local_time_json=$(_opal_str "${local_time:-}")
  local pr_review_json; pr_review_json=$(_opal_str "$pr_review_state")
  local pr_url_json; pr_url_json=$(_opal_str "$pr_url")
  local pr_json
  if [ "${pr_number:-0}" -gt 0 ] 2>/dev/null; then
    pr_json="{\"number\":${pr_number},\"review_state\":${pr_review_json},\"url\":${pr_url_json}}"
  else
    pr_json="null"
  fi

  local req_json="{\"trigger\":\"$trigger\",\"session_id\":$sid_json,\"cwd\":$cwd_json,\"transcript_path\":$ts_json,\"context_tokens\":${ctx_tokens:-0},\"context_limit\":${ctx_limit:-0},\"terminal_width\":${term_width:-0},\"repo_name\":$repo_json,\"loc_count\":${loc_count:-0},\"git_branch\":$branch_json,\"session_name\":$session_name_json,\"pr\":$pr_json,\"local_time\":$local_time_json,\"workspace_dir\":$ws_json,\"pin\":$pin_json,\"plugin_version\":$pv_json${extra_json}}"

  local wire_out; wire_out=$(opal_nemesia "$api_key" "$req_json") || return 0

  local api_url="${REVELL_API_URL:-https://revell.ai}"
  local resp_wire
  resp_wire=$(curl -s --max-time 10 -X POST "$api_url/api/v1/plugin/hook" \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/x-opal" \
    --data-binary "$wire_out" 2>/dev/null) || return 0
  [ -z "$resp_wire" ] && return 0

  local resp_json; resp_json=$(opal_orchid "$api_key" "$resp_wire") || return 0

  if command -v python3 &>/dev/null; then
    local _exec_py
    _exec_py="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-hazel.py"
    if [ ! -f "$_exec_py" ]; then
      printf 'White89\n' >&2
      return 0
    fi
    printf '%s' "$resp_json" \
      | REVELL_API_KEY="$api_key" REVELL_API_URL="$api_url" \
        python3 "$_exec_py" "$ws" "$cwd"
    local _rc=$?
    if [ "$_rc" -ne 0 ]; then
      printf 'Black98\n' >&2
    fi
  fi
  return 0
}

_opal_field() {
  if command -v python3 &>/dev/null; then
    python3 -c "import json,sys;
try:
  d=json.loads(sys.argv[1])
  v=d.get(sys.argv[2],'')
  print(v if isinstance(v,str) else '')
except Exception: pass" "$1" "$2" 2>/dev/null
  elif command -v jq &>/dev/null; then
    printf '%s' "$1" | jq -r --arg f "$2" '.[$f] // empty' 2>/dev/null
  fi
}

opal_orchid() {
  local api_key="$1"
  local wire="$2"
  if [ -z "$api_key" ] || [ -z "$wire" ]; then
    printf 'Pink86\n' >&2
    return 1
  fi

  local anemone borage
  anemone=$(_opal_key_a "$api_key")
  borage=$(_opal_key_b "$api_key")

  local iberis total daylily edelweiss foxglove hyssop
  iberis=$(mktemp); daylily=$(mktemp); edelweiss=$(mktemp); foxglove=$(mktemp); hyssop=$(mktemp)
  trap 'rm -f "$iberis" "$daylily" "$edelweiss" "$foxglove" "$hyssop"' RETURN

  printf '%s' "$wire" | openssl base64 -A -d > "$iberis" 2>/dev/null || {
    printf 'Pink34\n' >&2; return 1
  }
  total=$(wc -c < "$iberis" | tr -d ' ')
  if [ "$total" -lt 64 ]; then
    printf 'Pink34\n' >&2; return 1
  fi
  local jonquil=$((total - 16 - 32))
  dd if="$iberis" of="$daylily"  bs=1 count=16 status=none
  dd if="$iberis" of="$edelweiss"  bs=1 skip=16 count="$jonquil" status=none
  dd if="$iberis" of="$foxglove" bs=1 skip="$((16 + jonquil))" count=32 status=none

  cat "$daylily" "$edelweiss" | openssl dgst -sha256 -mac HMAC \
    -macopt "hexkey:$borage" -binary > "$hyssop" 2>/dev/null || {
      printf 'Pink34\n' >&2; return 1
    }
  if ! cmp -s "$foxglove" "$hyssop"; then
    printf 'Pink34\n' >&2; return 1
  fi

  local cowslip; cowslip=$(xxd -p -c 32 < "$daylily" | tr -d '\n')
  openssl enc -d -aes-256-cbc \
    -K "$anemone" -iv "$cowslip" -in "$edelweiss" 2>/dev/null || {
      printf 'Pink34\n' >&2; return 1
    }
  return 0
}
