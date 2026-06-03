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
docs/godot_codex_reference_upgrade_v2/CODEX_CURRENT_REQUIRED_SCOPE.md
docs/godot_codex_reference_upgrade_v2/CODEX_MULTIPLAYER_FRIEND_BOT_FILL.md
docs/godot_codex_reference_upgrade_v2/CODEX_25_PLAYER_DEATHMATCH_MODE.md
docs/godot_codex_reference_upgrade_v2/CODEX_ART_DIRECTION.md
```

## Non-negotiable project direction

Build a complete scoped Godot 4.x top-down hero arena / MOBA-lite game using:

- typed GDScript,
- Godot client,
- Godot headless authoritative match server,
- Nakama-compatible backend boundary,
- 3v3 Team Arena,
- 25 Player Deathmatch with no teams,
- friend-capable multiplayer with bot fill,
- server-authoritative combat, cooldowns, deaths, respawns, scoring, objectives/ranking, bots, and match results,
- data-driven content JSON,
- cohesive simple arcade art direction,
- readable heroes, ability icons, VFX, arena, HUD, menu, mode select, pause, and result screens,
- headless validation, parse checks, protocol checks, and bot soak tests for both modes,
- player-facing menu, mode select, match, HUD, pause, and result screens.

Do not replace this with a local-only prototype. Early features must still use the final boundaries: input frames, simulation ticks, server-owned truth, snapshots, and content validation.

Do not ask the user to manually finish the required game path after the prompt. The one-prompt challenge target is a complete small game, not a mockup, not a prototype, and not a partial vertical slice.
