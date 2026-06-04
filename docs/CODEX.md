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

## For the completion rescue pass

The previous challenge runs produced useful systems but failed strict completion gates. Before rebuilding anything, read:

```text
docs/godot_codex_reference_upgrade_v2/CODEX_COMPLETION_RESCUE_PASS.md
docs/godot_codex_reference_upgrade_v2/CODEX_ONE_PROMPT_PRODUCT_QUALITY_GATE.md
docs/godot_codex_reference_upgrade_v2/CODEX_MOBA_SURVIVAL_GENRE_GATE.md
```

The rescue pass must fix failed gates in the existing project: MOBA Survival genre authenticity, rendered UI QA, product-quality/art direction, real friend-capable transport, live backend validation where Docker is available, and strict final gate reporting.

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
docs/godot_codex_reference_upgrade_v2/CODEX_MOBA_SURVIVAL_GENRE_GATE.md
docs/godot_codex_reference_upgrade_v2/CODEX_MULTIPLAYER_FRIEND_BOT_FILL.md
docs/godot_codex_reference_upgrade_v2/CODEX_25_PLAYER_DEATHMATCH_MODE.md
docs/godot_codex_reference_upgrade_v2/CODEX_ART_DIRECTION.md
docs/godot_codex_reference_upgrade_v2/CODEX_ONE_PROMPT_PRODUCT_QUALITY_GATE.md
docs/godot_codex_reference_upgrade_v2/CODEX_RUNTIME_VISUAL_QA.md
```

## Non-negotiable project direction

Build a complete scoped Godot 4.x MOBA Survival game using:

- typed GDScript,
- Godot client,
- Godot headless authoritative match server,
- Nakama-compatible backend boundary,
- MOBA-style direct hero controls with 2 normal skills and 1 ultimate,
- battle-royale/survival-style large scrolling map flow,
- 3v3 squad survival objective mode,
- 25 Player Deathmatch / survival free-for-all with no teams,
- friend-capable multiplayer with bot fill,
- server-authoritative combat, cooldowns, deaths, respawns, scoring, objectives/ranking, safe-zone/danger pressure, bots, and match results,
- data-driven content JSON,
- cohesive simple arcade art direction that does not look like raw primitives, tank game, or default Godot UI,
- readable heroes, ability icons, VFX, large map, minimap/radar/directional awareness, HUD, menu, mode select, pause, and result screens,
- product-quality and MOBA Survival genre review from screenshots, not only automated green checks,
- runtime/visual QA for UI overlap, text collisions, console errors, gameplay readability, network logs, map scale, and offscreen threat readability,
- headless validation, parse checks, protocol checks, bot soak tests, and playable-flow checks for both modes,
- player-facing menu, mode select, match, HUD, pause, and result screens.

Do not replace this with a local-only prototype. Early features must still use the final boundaries: input frames, simulation ticks, server-owned truth, snapshots, and content validation.

Do not ask the user to manually finish the required game path after the prompt. The one-prompt challenge target is a complete small MOBA Survival game, not a mockup, not a prototype, not a tiny arena shooter, and not a partial vertical slice.

Do not report `Complete` if the game works technically but still looks like a first prototype, programmer-art scene, raw Godot controls, tank arena, crowded single-screen deathmatch, or squares/circles-only game.
