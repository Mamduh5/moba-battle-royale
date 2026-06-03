#!/usr/bin/env bash
set -euo pipefail

godot --headless --path . --server   --port "${PORT:-24560}"   --env "${APP_ENV:-local}"   --mode "${MATCH_MODE:-mode_team_arena_3v3}"   --map "${MATCH_MAP:-map_sunken_arena}"
