#!/usr/bin/env python3
from pathlib import Path
import json
import sys

root = Path(__file__).resolve().parents[1]
errors = []

for path in root.rglob('*.json'):
    try:
        json.loads(path.read_text(encoding='utf-8'))
    except Exception as exc:
        errors.append(f'{path}: {exc}')

required = [
    'CODEX_BUILD_CONTRACT.md',
    'docs/24_exact_repository_layout.md',
    'docs/25_godot_class_contracts.md',
    'docs/26_cli_command_contract.md',
    'docs/27_network_payload_contracts.md',
    'docs/28_nakama_runtime_contract.md',
    'docs/30_first_30_codex_tasks.md',
]
for item in required:
    if not (root / item).exists():
        errors.append(f'Missing required file: {item}')

if errors:
    print('VERIFY FAILED')
    for error in errors:
        print('-', error)
    sys.exit(1)

print('VERIFY PASSED')
