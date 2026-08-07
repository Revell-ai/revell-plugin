#!/bin/bash
set -u
SESSION_ID="${1:-}"
PROJECT_DIR="${2:-$PWD}"

echo "session_id: ${SESSION_ID:-unavailable}"
echo "project_dir: $PROJECT_DIR"

if [ -n "$SESSION_ID" ] && [ -n "$PROJECT_DIR" ]; then
  sanitized=$(printf '%s' "$PROJECT_DIR" | tr / -)
  tf="$HOME/.claude/projects/$sanitized/$SESSION_ID.jsonl"
  echo "transcript_path: $tf"
  if [ -f "$tf" ]; then
    size=$(stat -c%s "$tf" 2>/dev/null || stat -f%z "$tf" 2>/dev/null || echo unavailable)
    lines=$(wc -l < "$tf" 2>/dev/null | tr -d ' ')
    mtime=$(stat -c%Y "$tf" 2>/dev/null || stat -f%m "$tf" 2>/dev/null)
    if [ -n "$mtime" ]; then
      mtime_iso=$(date -u -d "@$mtime" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || \
                  date -u -r "$mtime" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || \
                  echo unavailable)
    else
      mtime_iso=unavailable
    fi
    echo "transcript_size_bytes: $size"
    echo "transcript_lines: ${lines:-unavailable}"
    echo "transcript_last_touched: $mtime_iso"
    echo "transcript_present: true"
  else
    echo "transcript_present: false"
  fi
else
  echo "transcript_path: unavailable"
fi

echo "shell: ${SHELL:-unavailable}"
echo "shell_pid: $$"
echo "ppid: $PPID"
parent_cmd=$(ps -o comm= -p "$PPID" 2>/dev/null | tr -d ' ')
if [ -n "$parent_cmd" ]; then
  echo "parent_process: $parent_cmd"
else
  echo "parent_process: unavailable"
fi

if [ -n "${TMUX:-}" ]; then
  tmux_session=$(tmux display-message -p '#S' 2>/dev/null || echo unavailable)
  tmux_pane=$(tmux display-message -p '#{pane_id}' 2>/dev/null || echo unavailable)
  tmux_pid=$(tmux display-message -p '#{pid}' 2>/dev/null || echo unavailable)
  echo "tmux_session: $tmux_session"
  echo "tmux_pane: $tmux_pane"
  echo "tmux_server_pid: $tmux_pid"
else
  echo "tmux_session: none"
fi

container=none
if [ -f /proc/1/cgroup ]; then
  if grep -q docker /proc/1/cgroup 2>/dev/null; then
    container=docker
  elif grep -q lxc /proc/1/cgroup 2>/dev/null; then
    container=lxc
  elif grep -q containerd /proc/1/cgroup 2>/dev/null; then
    container=containerd
  fi
fi
echo "container: $container"

vm=none
if grep -qi microsoft /proc/version 2>/dev/null; then
  vm=WSL
elif [ -f /proc/xen/capabilities ]; then
  vm=Xen
elif [ -d /proc/vz ] && [ ! -d /proc/bc ]; then
  vm=OpenVZ
elif dmesg 2>/dev/null | grep -qi 'hypervisor detected' 2>/dev/null; then
  vm=hypervisor
fi
echo "vm: $vm"

[ -f "$HOME/.claude/settings.json" ]         && echo "claude_settings_user: present"    || echo "claude_settings_user: absent"
[ -f "$PROJECT_DIR/.claude/settings.json" ]  && echo "claude_settings_project: present" || echo "claude_settings_project: absent"
[ -f "$PROJECT_DIR/.claude/settings.local.json" ] && echo "claude_settings_local: present" || echo "claude_settings_local: absent"

ws_sanitized=$(printf '%s' "$PROJECT_DIR" | tr / -)
ws_env="$HOME/.claude/projects/$ws_sanitized/.opal-rosetta"
if [ -f "$ws_env" ]; then
  echo "opal_peony: workspace ($ws_env)"
elif [ -n "${REVELL_API_KEY:-}" ]; then
  echo "opal_peony: environment (REVELL_API_KEY)"
else
  echo "opal_peony: unresolved"
fi

echo "---"
echo "# CLAUDE_* environment"
env | grep -E '^CLAUDE_' | sort
