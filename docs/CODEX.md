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

## For the single-prompt complete-game challenge

Start here:

```text
docs/godot_codex_reference_upgrade_v2/CODEX_ONE_PROMPT_BUILD.md
```

That file defines the complete scoped game target, task order, acceptance gates, fallback behavior, and reporting format.

Also read:

```text
docs/godot_codex_reference_upgrade_v2/CODEX_COMPLETE_GAME_CONTRACT.md
```

## Non-negotiable project direction

Build a complete scoped Godot 4.x top-down hero arena / MOBA-lite game using:

- typed GDScript,
- Godot client,
- Godot headless authoritative match server,
- Nakama-compatible backend boundary,
- server-authoritative combat, cooldowns, deaths, scoring, objectives, bots, and match results,
- data-driven content JSON,
- headless validation, parse checks, protocol checks, and bot soak tests,
- player-facing menu, match, HUD, pause, and result screens.

Do not replace this with a local-only prototype. Early features must still use the final boundaries: input frames, simulation ticks, server-owned truth, snapshots, and content validation.

Do not ask the user to manually finish the required game path after the prompt. The one-prompt challenge target is a complete small game, not a mockup, not a prototype, and not a partial vertical slice.
