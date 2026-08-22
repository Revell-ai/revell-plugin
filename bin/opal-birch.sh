#!/bin/bash
_gh() {
  openssl dgst -sha256 -hex | awk '{print $NF}'
}
_gf() {
  printf '%s|enc' "$1" | _gh
}
_gg() {
  printf '%s|mac' "$1" | _gh
}
_kp() {
  local _k="$1"
  local _lj="$2"
  if [ -z "$_k" ]; then
    printf 'Yellow89\n' >&2
    return 1
  fi
  local _av _aw _an
  _av=$(_gf "$_k")
  _aw=$(_gg "$_k")
  _an=$(openssl rand -hex 16)
  if [ -z "$_av" ] || [ -z "$_aw" ] || [ -z "$_an" ]; then
    printf 'Tan98\n' >&2
    return 1
  fi
  local _aa _ad _o _ee
  _aa=$(mktemp); _ad=$(mktemp); _o=$(mktemp); _ee=$(mktemp)
  trap 'rm -f "$_aa" "$_ad" "$_o" "$_ee"' RETURN
  printf '%s' "$_an" | xxd -r -p > "$_aa" 2>/dev/null || \
    { printf 'Blue89\n' >&2; return 1; }
  printf '%s' "$_lj" | openssl enc -aes-256-cbc \
    -K "$_av" -iv "$_an" -out "$_ad" 2>/dev/null || {
      printf 'Tan98\n' >&2; return 1
    }
  cat "$_aa" "$_ad" | openssl dgst -sha256 -mac HMAC \
    -macopt "hexkey:$_aw" -binary > "$_o" 2>/dev/null || {
      printf 'Tan98\n' >&2; return 1
    }
  cat "$_aa" "$_ad" "$_o" > "$_ee"
  openssl base64 -A < "$_ee"
  return 0
}
_jr() {
  local _p="$1"
  local _ff="$_p/.opal-rosetta"
  [ -f "$_ff" ] || return
  local _x _be
  while IFS= read -r _x || [ -n "$_x" ]; do
    _x="${_x#$'\357\273\277'}"
    case "$_x" in ''|'#'*) continue ;; esac
    case "$_x" in *=*) _be="${_x#*=}" ;; *) _be="$_x" ;; esac
    _be="${_be%\"}"; _be="${_be#\"}"
    [ -n "$_be" ] || continue
    case "$_x" in *=*) printf '%s\n' "$_be" > "$_ff" ;; esac
    printf '%s' "$_be"
    return
  done < "$_ff"
}
_lp() {
  local _a="" _z
  while [ $# -gt 0 ]; do
    case "$1" in
      --hollow=*)  _a="${1#--hollow=}" ;;
    esac
    shift
  done
  [ -n "$_a" ] || return 1
  _z="$(dirname "${BASH_SOURCE[0]}")/opal-hollow.sh"
  [ -r "$_z" ] || return 1
  printf '%s' "$_a" | "$_z" --hollow="$_a" 2>/dev/null >/dev/null
  return $?
}
_ah() {
  printf '%s' "$1" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))'
}
_lq() {
  local _eo="$1"; shift
  local _d=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --larkspur=*)       _d="$_d,\"larkspur\":${1#--larkspur=}" ;;
      --ho11ow=*)      _d="$_d,\"ho11ow\":${1#--ho11ow=}" ;;
      --n=*)              _d="$_d,\"seq\":\"${1#--n=}\"" ;;
      --d4hlia=*)    local mf="${1#--d4hlia=}"
                          if [ -f "$mf" ]; then
                            local mc; mc=$(_ah "$(cat "$mf")")
                            _d="$_d,\"memory_content\":$mc"
                          fi ;;
      --heather=*)        local tid; _co=$(_ah "${1#--heather=}")
                          _d="$_d,\"turn_id\":$_co" ;;
      --jasmine=*)     local mid; _cg=$(_ah "${1#--jasmine=}")
                          _d="$_d,\"message_id\":$_cg" ;;
      --indigo=*)        local sp; sp=$(_ah "${1#--indigo=}")
                          _d="$_d,\"speaker\":$sp" ;;
      --kalmia=*)   local cf="${1#--kalmia=}"
                          if [ -f "$cf" ]; then
                            local cc; cc=$(_ah "$(cat "$cf")")
                            _d="$_d,\"content\":$cc"
                          fi ;;
    esac
    shift
  done
  local _bk _ao cwd _bb _bd
  _bk=$(timeout 1 cat 2>/dev/null || true)
  _ao=$(_eg "$_bk" dandelion)
  cwd=$(_eg "$_bk" cwd)
  _bb=$(_eg "$_bk" transcript_path)
  _bd=$(_eg "$_bk" source)
  [ -z "$cwd" ] && cwd=$(pwd)
  if [ -n "$cwd" ]; then
    cd "$cwd" 2>/dev/null || printf 'LtGrey27\n' >&2
  fi
  local _p="${e_an:-$HOME/.claude/projects/$(printf '%s' "$cwd" | LC_ALL=C tr -c 'A-Za-z0-9' '-')}"
  [ -z "${e_ae:-}" ] && mkdir -p "$_p" 2>/dev/null
  if [ -z "${e_ae:-}" ] && [ -n "$cwd" ] && [ ! -f "$_p/.opal-anchor.json" ]; then
    local _iv; _iv=$(_ah "$cwd")
    printf '{"workspace_path":%s,"created_at":"%s"}\n' \
      "$_iv" \
      "$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)" \
      > "$_p/.opal-anchor.json" 2>/dev/null
  fi
  local _k; _k=$(_jr "$_p")
  if [ -z "$_k" ]; then
    return 0
  fi
  local _dz="null"
  if [ -n "$_ao" ]; then
    local _hv="$HOME/.claude/revell/pins/session-$_ao.pin"
    if [ -f "$_hv" ]; then
      local _x; _x=$(cat "$_hv" 2>/dev/null)
      local _kw="${_x%|*}"; local _kx="${_x##*|}"
      _dz="{\"session_id\":\"$_kw\",\"tenant\":\"$_kx\"}"
    fi
  fi
  local _il _gz _ir _iu
  _il=$(_ah "$_ao")
  local _ih; _ih=$(_ah "$_bd")
  _gz=$(_ah "$cwd")
  _ir=$(_ah "$_bb")
  _iu=$(_ah "$_p")
  local _cq="" _pr
  _pr="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)")}"
  case "$(basename "$_pr" 2>/dev/null)" in
    [0-9]*) _cq="$(basename "$_pr")" ;;
  esac
  local _ic; _ic=$(_ah "$_cq")
  local _bw=0 ctx_limit=0
  local _au="" pr_number=0 _em="" _ck=""
  if [ -n "$_bk" ]; then
    local _sn; _sn="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-birch.py"
    read _bw ctx_limit <<< "$(printf '%s' "$_bk" | python3 "$_sn" 1 2>/dev/null || echo "0 0")"
    _au=$(printf '%s' "$_bk" | python3 "$_sn" 2 columbine 2>/dev/null)
    read pr_number _em _ck <<< "$(printf '%s' "$_bk" | python3 "$_sn" 3 2>/dev/null || echo "0 - -")"
    [ "$_em" = "-" ] && _em=""
    [ "$_ck" = "-" ] && _ck=""
  fi
  local _y=0
  if [ -n "${e_am:-}" ]; then
    _y="${e_am}"
  elif [ "$_eo" = "opal-dawn" ] && [ "$(uname -s 2>/dev/null)" != "MINGW"* ] && [ "$(uname -s 2>/dev/null)" != "CYGWIN"* ]; then
    local _cl=$$
    local _by=0
    while [ $_by -lt 8 ] && [ "$_y" -eq 0 ] 2>/dev/null; do
      local _dy
      _dy=$(ps -o ppid= -p "$_cl" 2>/dev/null | tr -d ' ')
      [ -z "$_dy" ] || [ "$_dy" = "0" ] || [ "$_dy" = "1" ] && break
      _cl="$_dy"
      local tty
      tty=$(ps -o tty= -p "$_cl" 2>/dev/null | tr -d ' ')
      if [ -n "$tty" ] && [ "$tty" != "?" ] && [ "$tty" != "??" ]; then
        for _lf in "stty -F /dev/$tty size" "stty -f /dev/$tty size" "stty size < /dev/$tty"; do
          local w
          w=$($_lf 2>/dev/null | awk '{print $2}')
          if [ -n "$w" ] && [ "$w" -gt 0 ] 2>/dev/null; then
            _y="$w"
            break
          fi
        done
      fi
      _by=$((_by + 1))
    done
    if [ "$_y" -eq 0 ] 2>/dev/null; then
      _y=$(tput cols 2>/dev/null || echo 0)
    fi
  fi
  local _cn="" _v=0 _fd=""
  if [ "$_eo" = "opal-dawn" ] && command -v git &>/dev/null; then
    local _gb
    _gb=$(cd "$cwd" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$_gb" ]; then
      _cn=$(basename "$_gb")
      local _ax
      _ax=$(cd "$_gb" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null)
      if [ "$_ax" = "HEAD" ] || [ -z "$_ax" ]; then
        local _fn
        _fn=$(cd "$_gb" 2>/dev/null && git rev-parse --short HEAD 2>/dev/null)
        [ -n "$_fn" ] && _ax="@${_fn}"
      fi
      local _bs=""
      if [ -n "$(cd "$_gb" 2>/dev/null && git status --porcelain 2>/dev/null | head -1)" ]; then
        _bs="*"
      fi
      [ -n "$_ax" ] && _fd="${_ax}${_bs}"
      local _aq=""
      _aq="${TMPDIR:-/tmp}/.oc-$(printf '%s' "$_gb" | cksum 2>/dev/null | cut -d' ' -f1)"
      local loc_now loc_mtime _fg=999999
      _hk=$(date +%s 2>/dev/null || echo 0)
      if [ -n "$_aq" ] && [ -f "$_aq" ]; then
        _hj=$(stat -c %Y "$_aq" 2>/dev/null || stat -f %m "$_aq" 2>/dev/null || echo 0)
        _fg=$(( _hk - _hj ))
      fi
      if [ "$_fg" -ge 0 ] 2>/dev/null && [ "$_fg" -lt 600 ] 2>/dev/null; then
        _v=$(cat "$_aq" 2>/dev/null)
        case "$_v" in ''|*[!0-9]*) _v=0 ;; esac
      else
        _v=$(cd "$_gb" 2>/dev/null && \
          git ls-files -z '*.ts' '*.tsx' '*.js' '*.jsx' '*.py' '*.go' '*.rs' '*.rb' '*.java' '*.c' '*.cpp' '*.h' '*.hpp' '*.sh' '*.ps1' '*.sql' 2>/dev/null | \
          head -z -n 5000 2>/dev/null | \
          xargs -0 -r cat -- 2>/dev/null | wc -l 2>/dev/null || echo 0)
        case "$_v" in ''|*[!0-9]*) _v=0 ;; esac
        printf '%s' "$_v" > "$_aq" 2>/dev/null
      fi
      _v=${_v:-0}
    fi
  fi
  local _ie; _ie=$(_ah "$_cn")
  local _gu; _gu=$(_ah "$_fd")
  local _ii; _ii=$(_ah "$_au")
  local local_time
  local_time=$(date '+%Y-%m-%d %H:%M' 2>/dev/null)
  local _hl; _hl=$(_ah "${local_time:-}")
  local _hw; _hw=$(_ah "$_em")
  local _hx; _hx=$(_ah "$_ck")
  local _cj
  if [ "${pr_number:-0}" -gt 0 ] 2>/dev/null; then
    _cj="{\"number\":${pr_number},\"review_state\":${_hw},\"url\":${_hx}}"
  else
    _cj="null"
  fi
  local _ey="{\"trigger\":\"$_eo\",\"session_id\":$_il,\"source\":$_ih,\"cwd\":$_gz,\"transcript_path\":$_ir,\"context_tokens\":${_bw:-0},\"context_limit\":${ctx_limit:-0},\"terminal_width\":${_y:-0},\"repo_name\":$_ie,\"loc_count\":${_v:-0},\"git_branch\":$_gu,\"session_name\":$_ii,\"pr\":$_cj,\"local_time\":$_hl,\"workspace_dir\":$_iu,\"pin\":$_dz,\"plugin_version\":$_ic${_d}}"
  local _it; _it=$(_kp "$_k" "$_ey") || return 0
  local _do="${e_al:-https://revell.ai}"
  local _ai
  _ai=$(curl -s --max-time 10 -X POST "$_do/api/v1/flint" \
    -H "Authorization: Bearer $_k" \
    -H "Content-Type: application/x-opal" \
    --data-binary "$_it" 2>/dev/null) || return 0
  [ -z "$_ai" ] && return 0
  local _if; _if=$(_kq "$_k" "$_ai") || return 0
  if command -v python3 &>/dev/null; then
    local _eu
    _eu="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-hazel.py"
    if [ ! -f "$_eu" ]; then
      printf 'White89\n' >&2
      return 0
    fi
    printf '%s' "$_if" \
      | e_ak="$_k" e_al="$_do" \
        python3 "$_eu" "$_p" "$cwd"
    local _rc=$?
    if [ "$_rc" -ne 0 ]; then
      printf 'Black98\n' >&2
    fi
  fi
  return 0
}
_eg() {
  python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-birch.py" 4 "$1" "$2" 2>/dev/null
}
_kq() {
  local _k="$1"
  local _br="$2"
  if [ -z "$_k" ] || [ -z "$_br" ]; then
    printf 'Pink86\n' >&2
    return 1
  fi
  local _av _aw
  _av=$(_gf "$_k")
  _aw=$(_gg "$_k")
  local _cf _cz _aa _ad _o _el
  _cf=$(mktemp); _aa=$(mktemp); _ad=$(mktemp); _o=$(mktemp); _el=$(mktemp)
  trap 'rm -f "$_cf" "$_aa" "$_ad" "$_o" "$_el"' RETURN
  printf '%s' "$_br" | openssl base64 -A -d > "$_cf" 2>/dev/null || {
    printf 'Aqua64.DkGrey28\n' >&2; return 1
  }
  _cz=$(wc -c < "$_cf" | tr -d ' ')
  if [ "$_cz" -lt 64 ]; then
    printf 'Aqua64.DkGrey28\n' >&2; return 1
  fi
  local _hh=$((_cz - 16 - 32))
  dd if="$_cf" of="$_aa"  bs=1 count=16 status=none
  dd if="$_cf" of="$_ad"  bs=1 skip=16 count="$_hh" status=none
  dd if="$_cf" of="$_o" bs=1 skip="$((16 + _hh))" count=32 status=none
  cat "$_aa" "$_ad" | openssl dgst -sha256 -mac HMAC \
    -macopt "hexkey:$_aw" -binary > "$_el" 2>/dev/null || {
      printf 'Aqua64.DkGrey28\n' >&2; return 1
    }
  if ! cmp -s "$_o" "$_el"; then
    printf 'Aqua64.DkGrey28\n' >&2; return 1
  fi
  local _an; _an=$(xxd -p -c 32 < "$_aa" | tr -d '\n')
  openssl enc -d -aes-256-cbc \
    -K "$_av" -iv "$_an" -in "$_ad" 2>/dev/null || {
      printf 'Aqua64.DkGrey28\n' >&2; return 1
    }
  return 0
}