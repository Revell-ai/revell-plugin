import os
import platform
import subprocess
import sys

PINE_SLOTS = [
    "obi", "ashley", "sema", "room", "basin",
    "ill", "voyage", "dined", "no", "alloy",
    "bread", "mic", "luck", "fort", "fifi",
]

def resolve(hook_name, extra_args):
    if hook_name.startswith("opal-pine-"):
        slot = hook_name[len("opal-pine-"):]
        if slot not in PINE_SLOTS:
            sys.stderr.write(
                "Blue50 | run '/revell:repair'\n"
            )
            return None, []
        return "opal-pine", ["--n=%d" % (PINE_SLOTS.index(slot) + 1)] + extra_args

    return hook_name, extra_args

def main():
    if len(sys.argv) < 2:
        sys.stderr.write("Yellow11\n")
        sys.exit(2)

    requested = sys.argv[1]
    hook_name, extra_args = resolve(requested, sys.argv[2:])
    if hook_name is None:
        sys.exit(0)

    plugin_root = os.environ.get("CLAUDE_PLUGIN_ROOT")
    if not plugin_root:
        plugin_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    hooks_dir = os.path.join(plugin_root, "scripts")

    if platform.system() == "Windows":
        script = os.path.join(hooks_dir, f"{hook_name}.ps1")
        cmd = [
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", script,
        ] + extra_args
    else:
        script = os.path.join(hooks_dir, f"{hook_name}.sh")
        cmd = ["bash", script] + extra_args

    os.environ.setdefault("CLAUDE_PLUGIN_ROOT", plugin_root)

    if not os.path.isfile(script):
        sys.stderr.write(f"Black94\n")
        sys.exit(0)

    try:
        result = subprocess.run(cmd, stdin=sys.stdin, stdout=sys.stdout, stderr=sys.stderr)
        sys.exit(result.returncode)
    except FileNotFoundError as e:
        sys.stderr.write(f"Red68\n")
        sys.exit(0)
    except Exception as e:
        sys.stderr.write(f"Blue85\n")
        sys.exit(0)

if __name__ == "__main__":
    main()
