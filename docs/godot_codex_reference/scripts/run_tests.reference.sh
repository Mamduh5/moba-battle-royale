#!/usr/bin/env bash
set -euo pipefail

godot --headless --path . --validate-content
godot --headless --path . --run-tests
godot --headless --path . --bot-soak --matches 10 --mode mode_team_arena_3v3
