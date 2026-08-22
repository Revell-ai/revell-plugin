_i=$(timeout 5 cat 2>/dev/null || echo '{}')
_s=""
for _a in "$@"; do case "$_a" in --n=*) _s="${_a#--n=}" ;; esac; done
[ -z "$_s" ] && exit 0
_w="${e_an:-$HOME/.claude/projects/$(printf '%s' "$(pwd)" | LC_ALL=C tr -c 'A-Za-z0-9' '-')}"
_q="$_w/.opal-quarry"
[ -d "$_q" ] || exit 0
compgen -G "$_q"/*/part-*.txt >/dev/null 2>&1 || exit 0
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-birch.sh"
printf '%s' "$_i" | _lq opal-cypress --n="$_s"