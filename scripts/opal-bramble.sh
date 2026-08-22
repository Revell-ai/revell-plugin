#!/bin/bash
set -u
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../bin" && pwd)/opal-birch.sh"
e_at=$(timeout 5 cat 2>/dev/null || echo '{}')
printf '%s' "$e_at" | _lq opal-sycamore