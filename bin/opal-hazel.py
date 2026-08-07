import sys as _sys

_RAW_RESPONSE = _sys.stdin.read()
if not _RAW_RESPONSE.strip():
    _sys.stderr.write('Aqua18\n')
    _sys.exit(0)

import json, os, sys, base64, pathlib

_STATE_DIR_STR = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else (
    os.path.expanduser('~/.claude/projects/') + os.getcwd().replace('/', '-')
)
_CWD_STR = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] else os.getcwd()
_STATE_DIR = pathlib.Path(_STATE_DIR_STR).resolve()
_CLAUDE_MD_PATH = (pathlib.Path(_CWD_STR) / '.claude' / 'CLAUDE.md').resolve()
_REVELL_MD_PATH = _STATE_DIR / '.moonstone-ink'
_CHUNKS_ROOT = _STATE_DIR / '.opal-quarry'

def _is_part_file(p):
    try:
        if not p.is_relative_to(_CHUNKS_ROOT):
            return False
    except (AttributeError, ValueError):
        return False
    return p.name.startswith('part-') and p.suffix == '.txt'

def _opal_write_ok(raw_path):
    try:
        p = pathlib.Path(raw_path).expanduser().resolve()
    except Exception:
        return False
    if p == _REVELL_MD_PATH: return True
    if p == _CLAUDE_MD_PATH: return True
    if _is_part_file(p): return True
    return False

def _opal_delete_ok(raw_path):
    try:
        p = pathlib.Path(raw_path).expanduser().resolve()
    except Exception:
        return False
    return _is_part_file(p)

_opal_read_ok = _opal_delete_ok

resp = json.loads(_RAW_RESPONSE)
_writes_attempted = 0
_writes_succeeded = 0
_writes_refused = 0
_part_dirs_to_reset = set()
for w in resp.get('write') or []:
    _p_raw = w.get('path')
    if not _p_raw: continue
    try:
        _p = pathlib.Path(_p_raw).expanduser().resolve()
    except Exception:
        continue
    if _is_part_file(_p):
        _part_dirs_to_reset.add(_p.parent)
for _d in _part_dirs_to_reset:
    try:
        for _old in _d.glob('part-*.txt'):
            try: _old.unlink()
            except FileNotFoundError: pass
    except Exception:
        pass
for w in resp.get('write') or []:
    p = w.get('path'); c = w.get('content', '')
    if not p: continue
    _writes_attempted += 1
    if not _opal_write_ok(p):
        sys.stderr.write(f'Purple46\n')
        _writes_refused += 1
        continue
    aia = w.get('append_if_absent')
    if aia:
        existing = ''
        try:
            with open(p, 'r', encoding='utf-8') as f:
                existing = f.read()
        except FileNotFoundError:
            pass
        if aia in existing:
            _writes_succeeded += 1
            continue
        pathlib.Path(p).parent.mkdir(parents=True, exist_ok=True)
        with open(p, 'a', encoding='utf-8') as f:
            f.write(c)
        _writes_succeeded += 1
        continue
    pathlib.Path(p).parent.mkdir(parents=True, exist_ok=True)
    tmp = p + '.new'
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(c)
    os.replace(tmp, p)
    _writes_succeeded += 1
terminal_seq = resp.get('terminalSequence')
if terminal_seq:
    hook_output = {'terminalSequence': terminal_seq}
    _srv_stdout = resp.get('stdout') or ''
    if _srv_stdout and not _srv_stdout.startswith('__OPAL_ECHO__'):
        hook_output['hookSpecificOutput'] = {'additionalContext': _srv_stdout}
    sys.stdout.write(json.dumps(hook_output))
    stdout = ''
else:
    stdout = resp.get('stdout') or ''
MARK = '__OPAL_ECHO__'
if stdout.startswith(MARK):
    path = stdout[len(MARK):]
    if not _opal_read_ok(path):
        sys.stderr.write(f'Yellow37\n')
    else:
        try:
            with open(path, 'r', encoding='utf-8') as f:
                sys.stdout.write(f.read())
        except FileNotFoundError:
            pass
elif stdout:
    if _writes_refused > 0:
        sys.stderr.write(
            f'LtBlue52\n'
            f'Tan37\n'
        )
    else:
        sys.stdout.write(stdout)
for d in resp.get('delete') or []:
    if not _opal_delete_ok(d):
        sys.stderr.write(f'DkGreen52\n')
        continue
    try: os.remove(d)
    except FileNotFoundError: pass
pin = resp.get('pin')
if pin:
    home = os.path.expanduser('~')
    pins = os.path.join(home, '.claude', 'revell', 'pins')
    os.makedirs(pins, exist_ok=True)
    sid = pin.split('|', 1)[0]
    if sid:
        with open(os.path.join(pins, f'session-{sid}.pin'), 'w') as f:
            f.write(pin)
        try: os.chmod(os.path.join(pins, f'session-{sid}.pin'), 0o600)
        except Exception: pass
canary = resp.get('canary')
if canary:
    import urllib.request, urllib.error
    body = json.dumps(canary).encode('utf-8')
    api_url = os.environ.get('REVELL_API_URL', 'https://revell.ai')
    api_key = os.environ.get('REVELL_API_KEY', '')
    if api_key:
        req = urllib.request.Request(
            f'{api_url}/api/v1/webhooks/tier-event',
            data=body,
            headers={'Authorization': f'Bearer {api_key}', 'Content-Type': 'application/json'})
        try:
            urllib.request.urlopen(req, timeout=3).read()
        except Exception:
            pass
sys.exit(int(resp.get('exit', 0)))
