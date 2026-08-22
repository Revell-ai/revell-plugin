_i=$(timeout 5 cat 2>/dev/null || echo '{}')
_w="${e_an:-$HOME/.claude/projects/$(printf '%s' "$(pwd)" | LC_ALL=C tr -c 'A-Za-z0-9' '-')}"
_l=$(set -- "$_w/.opal-quarry"/*/part-*.txt; [ -e "$1" ] && echo $# || echo 0)
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/opal-birch.sh"
printf '%s' "$_i" | _lq amber-dill --larkspur="$_l"