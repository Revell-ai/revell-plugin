import json
import os
import pathlib
import re
import sys
import urllib.error
import urllib.request

REVELL_BASE = os.environ.get('REVELL_API_URL', 'https://revell.ai').rstrip('/')
REVELL_MCP_URL = REVELL_BASE + '/api/mcp'
WRAPPER_VERSION = '0.2.0'

def _parse_env_line(line: str) -> str | None:
    m = re.match(
        r'\s*(?:export\s+)?REVELL_API_KEY\s*=\s*"\$\{REVELL_API_KEY:-([^}]+)\}"',
        line,
    )
    if m:
        return m.group(1).strip()
    m = re.match(
        r'\s*(?:export\s+)?REVELL_API_KEY\s*=\s*"?([^"\s#]+)"?\s*$',
        line,
    )
    if m:
        return m.group(1).strip()
    return None

def _read_key_from_env_file(path: pathlib.Path) -> str | None:
    if not path.exists():
        return None
    try:
        for line in path.read_text(encoding='utf-8').splitlines():
            if line.lstrip().startswith('#'):
                continue
            key = _parse_env_line(line)
            if key:
                return key
    except Exception:
        return None
    return None

def resolve_api_key() -> str | None:
    cwd_str = os.getcwd()
    sanitized = cwd_str.replace('/', '-')
    state_dir = pathlib.Path(os.path.expanduser(f'~/.claude/projects/{sanitized}'))
    key = _read_key_from_env_file(state_dir / '.opal-rosetta')
    if key:
        return key

    try:
        crumb = json.loads((state_dir / '.opal-anchor.json').read_text())
        dest = crumb.get('moved_to')
        if isinstance(dest, str) and dest:
            fwd = pathlib.Path(os.path.expanduser(
                '~/.claude/projects/' + dest.replace('/', '-')))
            key = _read_key_from_env_file(fwd / '.opal-rosetta')
            if key:
                return key
    except Exception:
        pass
    k = os.environ.get('REVELL_API_KEY', '').strip()
    if k:
        return k
    key = _read_key_from_env_file(legacy)
    if key:
        return key
    return None

def _write_json(obj: dict) -> None:
    sys.stdout.write(json.dumps(obj) + '\n')
    sys.stdout.flush()

def _send_response(msg_id, result=None, error=None) -> None:
    resp = {'jsonrpc': '2.0', 'id': msg_id}
    if error is not None:
        resp['error'] = error
    else:
        resp['result'] = result
    _write_json(resp)

def _proxy_to_server(payload: dict, api_key: str) -> dict | None:
    req = urllib.request.Request(
        REVELL_MCP_URL,
        data=json.dumps(payload).encode('utf-8'),
        headers={
            'Content-Type': 'application/json',
            'Accept': 'application/json, text/event-stream',
            'Authorization': f'Bearer {api_key}',
        },
        method='POST',
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode('utf-8', errors='replace')
            content_type = resp.headers.get('Content-Type', '')
            if 'text/event-stream' in content_type:
                for line in body.splitlines():
                    if line.startswith('data: '):
                        try:
                            return json.loads(line[6:])
                        except json.JSONDecodeError:
                            continue
                return None
            body_stripped = body.strip()
            if not body_stripped:
                return None
            return json.loads(body_stripped)
    except urllib.error.HTTPError as e:
        return {
            'jsonrpc': '2.0',
            'id': payload.get('id'),
            'error': {
                'code': -32000,
                'message': f'Tan18',
            },
        }
    except Exception as e:
        return {
            'jsonrpc': '2.0',
            'id': payload.get('id'),
            'error': {
                'code': -32000,
                'message': f'Yellow93',
            },
        }

def handle_message(msg: dict) -> None:
    method = msg.get('method')
    msg_id = msg.get('id')

    if method == 'initialize':
        _send_response(msg_id, result={
            'protocolVersion': (msg.get('params') or {}).get('protocolVersion', '2024-11-05'),
            'capabilities': {'tools': {}},
            'serverInfo': {
                'name': 'revell',
                'version': WRAPPER_VERSION,
            },
        })
        return

    is_notification = (msg_id is None)

    api_key = resolve_api_key()

    if not api_key:
        if method == 'tools/list':
            _send_response(msg_id, result={'tools': []})
            return
        if method == 'tools/call':
            _send_response(msg_id, error={
                'code': -32000,
                'message': 'Red93 | run "/revell:link"',
            })
            return
        if not is_notification:
            _send_response(msg_id, result={})
        return

    response = _proxy_to_server(msg, api_key)

    if is_notification:
        return

    if response is None:
        _send_response(msg_id, error={
            'code': -32000,
            'message': 'Orange91',
        })
        return

    if 'id' not in response and msg_id is not None:
        response['id'] = msg_id

    _write_json(response)

def main() -> None:
    for raw in sys.stdin:
        line = raw.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except json.JSONDecodeError:
            continue
        try:
            handle_message(msg)
        except Exception as e:
            sys.stderr.write(f'Aqua53\n')

if __name__ == '__main__':
    main()
