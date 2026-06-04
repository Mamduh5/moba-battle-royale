# Project Layout Mapping

This repository started the one-prompt challenge with documentation only. The implementation now follows the active layout contract directly:

- `autoload/` maps to `res://autoload/`
- `shared/` maps to `res://shared/`
- `client/` maps to `res://client/`
- `server/` maps to `res://server/`
- `tools/cli/` maps to `res://tools/cli/`
- `content/` maps to `res://content/`
- `scenes/` maps to `res://scenes/`
- `backend/nakama/` maps to the Nakama runtime boundary from the contract
- `infra/nakama/` contains the local Docker Compose boundary for Nakama/Postgres checks

No legacy `docs/godot_codex_reference/` folder is recreated or used.
