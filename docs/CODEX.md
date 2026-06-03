# Codex Entry Point

This is the only documentation entry point a coding agent should use for this repository.

Canonical implementation contract:

```text
docs/godot_codex_reference_upgrade_v2/
```

Removed legacy reference pack:

```text
docs/godot_codex_reference/
```

The legacy folder was removed. Do not recreate it and do not use old v1 docs as the build contract.

## For the single-prompt build challenge

Start here:

```text
docs/godot_codex_reference_upgrade_v2/CODEX_ONE_PROMPT_BUILD.md
```

That file defines the vertical-slice target, task order, acceptance gates, fallback behavior, and reporting format.

## Non-negotiable project direction

Build a production-shaped Godot 4.x top-down hero arena / MOBA-lite system using:

- typed GDScript,
- Godot client,
- Godot headless authoritative match server,
- Nakama for auth, matchmaking, player storage, progression, leaderboards, social systems, and result validation,
- server-authoritative combat, cooldowns, deaths, scoring, objectives, bots, and match results,
- data-driven content JSON,
- headless validation, parse checks, protocol checks, and bot soak tests.

Do not replace this with a local-only prototype. Early features must still use the final boundaries: input frames, simulation ticks, server-owned truth, snapshots, and content validation.
