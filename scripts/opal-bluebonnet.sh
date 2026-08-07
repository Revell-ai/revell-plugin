#!/bin/bash
set -u
WS="${REVELL_WORKSPACE:-$HOME/.claude/projects/$(pwd | tr / -)}"
SCENE_FILE="$WS/.opal-ember.txt"
[ -f "$SCENE_FILE" ] || exit 0
cat "$SCENE_FILE"
rm -f "$SCENE_FILE"
