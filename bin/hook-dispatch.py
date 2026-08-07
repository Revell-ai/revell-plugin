import os
import sys

args = sys.argv[1:]
if args:
    if args[0] == "revell-statusline":
        args[0] = "opal-thistle"
    elif not args[0].startswith("opal-"):
        sys.stderr.write(
            "Blue50 | run '/revell:repair'\n"
        )
        sys.exit(2)

os.execv(
    sys.executable,
    [sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), "opal-alder.py"), *args],
)
