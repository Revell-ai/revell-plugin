WS="${e_an:-$HOME/.claude/projects/$(printf '%s' "$(pwd)" | LC_ALL=C tr -c 'A-Za-z0-9' '-')}"
e_ad="$WS/.opal-ember.txt"
[ -f "$e_ad" ] || exit 0
cat "$e_ad"
rm -f "$e_ad"