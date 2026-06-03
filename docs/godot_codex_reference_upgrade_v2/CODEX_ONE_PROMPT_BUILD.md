# Codex One-Prompt Complete Game Mission

This file is the controlling instruction for a coding agent attempting to build a complete scoped game from one prompt.

Do not brainstorm. Do not redesign the stack. Do not create an unrelated demo. Do not stop at a mockup, prototype, or partial vertical slice. Implement a complete small Godot hero-arena game inside the existing repository while preserving the final architecture.

## Required reading order

Read these files before editing:

1. `docs/CODEX.md`
2. `docs/godot_codex_reference_upgrade_v2/CODEX_COMPLETE_GAME_CONTRACT.md`
3. `docs/godot_codex_reference_upgrade_v2/CODEX_CURRENT_REQUIRED_SCOPE.md`
4. `docs/godot_codex_reference_upgrade_v2/CODEX_MULTIPLAYER_FRIEND_BOT_FILL.md`
5. `docs/godot_codex_reference_upgrade_v2/CODEX_25_PLAYER_DEATHMATCH_MODE.md`
6. `docs/godot_codex_reference_upgrade_v2/CODEX_ART_DIRECTION.md`
7. `docs/godot_codex_reference_upgrade_v2/CODEX_BUILD_CONTRACT.md`
8. `docs/godot_codex_reference_upgrade_v2/CODEX_RETRY_DEBUG_LOOP.md`
9. `docs/godot_codex_reference_upgrade_v2/docs/24_exact_repository_layout.md`
10. `docs/godot_codex_reference_upgrade_v2/docs/25_godot_class_contracts.md`
11. `docs/godot_codex_reference_upgrade_v2/docs/26_cli_command_contract.md`
12. `docs/godot_codex_reference_upgrade_v2/docs/27_network_payload_contracts.md`
13. `docs/godot_codex_reference_upgrade_v2/docs/28_nakama_runtime_contract.md`
14. `docs/godot_codex_reference_upgrade_v2/docs/33_testing_contract.md`
15. `docs/godot_codex_reference_upgrade_v2/docs/34_bot_contracts.md`
16. `docs/godot_codex_reference_upgrade_v2/docs/35_scene_ui_contracts.md`
17. `docs/godot_codex_reference_upgrade_v2/CODEX_ACCEPTANCE_GATES.md`
18. `docs/godot_codex_reference_upgrade_v2/CODEX_FAILURE_RECOVERY.md`

Use `docs/godot_codex_reference_upgrade_v2/docs/30_first_30_codex_tasks.md` as the build order, but apply the complete-game scope in this file.

## Tool and run policy

Codex is expected to run the work, not only write files. If normal development tools are missing, attempt to bootstrap them through the available environment or report the exact blocker. Do not stop on the first failed command. Follow `CODEX_RETRY_DEBUG_LOOP.md`.

## Build target

Implement a complete scoped local game:

```text
Godot client -> Godot headless authoritative match server -> local Nakama-compatible backend boundary
```

The game must be playable from launch to result screen without requiring the user to manually create scenes, wire nodes, edit project settings, or finish missing gameplay.

## Required player-facing game flow

The finished repository must support this flow:

1. launch game,
2. load content,
3. show main menu,
4. choose 3v3 Team Arena or 25 Player Deathmatch,
5. start match,
6. select or auto-assign hero,
7. load arena,
8. spawn player, friends if connected, and bot-filled remaining slots,
9. play a full selected-mode match,
10. finish by score limit or timer,
11. show victory/defeat or ranking result screen,
12. allow restart or return to menu.

## Required game content

Implement at least:

- 3 playable heroes,
- 3 abilities per hero: basic attack, secondary skill, ultimate or high-impact skill,
- 1 complete arena map with spawn points, obstacles, bounds, and objective/score positions,
- 2 complete modes: `3v3_team_arena` and `25_player_deathmatch`,
- bot fill for all empty slots in both modes,
- friend-capable multiplayer path with bot fill,
- health, damage, cooldowns, deaths, respawn, score, timer, ranking, and match end,
- HUD for health, cooldowns, score/rank, timer, and match state,
- main menu, mode select, loading/match start state, pause/escape menu, result screen,
- simple but cohesive visual presentation following `CODEX_ART_DIRECTION.md`,
- audio/VFX hooks where feasible, with safe no-asset fallbacks.

Do not call required game content placeholder, mock, or prototype inside player-facing screens. Simple art is acceptable when it is consistent, readable, and functional.

## Required technical systems

The complete game must include:

- repository layout from the exact layout contract,
- required autoloads configured or documented with exact `project.godot` entries,
- typed GDScript core classes,
- content JSON for heroes, abilities, maps, modes, and bot profiles,
- content loader and validator,
- CLI command router,
- network envelope, input frame, snapshot frame, and codec,
- simulation state and fixed-tick simulation world,
- movement, health, damage, cooldowns, abilities, deaths, respawns, team scoring, deathmatch ranking, and victory resolution,
- authoritative match room with complete bot-filled local match support,
- bots submitting the same `InputFrame` objects as human players,
- local server transport abstraction,
- friend join path via LAN/IP, room code, dev token, or local adapter,
- handshake and input/snapshot message models,
- client connection state machine,
- input sampler,
- snapshot presentation boundary,
- HUD state facade,
- local backend adapter compatible with the Nakama contract,
- validation, parse, protocol, run-tests, and bot-soak commands for both modes where feasible,
- structured debug logs through `DebugBus`.

## Scope control

Do not attempt to build a giant commercial game. Build a complete small game.

Do not implement:

- ranked matchmaking,
- cosmetics economy,
- real-money purchases,
- large hero roster beyond the required 3 heroes,
- complex map art,
- production deployment automation,
- advanced anti-cheat,
- full reconnect support,
- complete replay tooling,
- all MOBA lane systems.

Create extension points for those systems only when the contract requires them.

## Implementation order

Work in this order. Do not skip ahead to visual polish before gameplay is complete.

1. Inspect the existing repository.
2. Create or map the exact repository layout.
3. Add `docs/PROJECT_LAYOUT_MAPPING.md` if any existing structure differs from the contract.
4. Add `project.godot` if missing and configure the minimum runnable scene/autoloads.
5. Add autoload scripts.
6. Add real content JSON for 3 heroes, their abilities, both modes, one map, and bot profiles.
7. Add content loader and validator.
8. Add CLI command router and `validate-content` command.
9. Add protocol models and codec.
10. Add simulation state, clock, config, and entity registry.
11. Add movement, health, damage, death, cooldown, respawn, team scoring, deathmatch ranking, and ability runtime.
12. Add `SimulationWorld.step_tick()`.
13. Add `MatchRoom` and complete bot-filled match lifecycle for both modes.
14. Add bot perception/brain/input builder for team and deathmatch behavior.
15. Add `bot-soak` command for both modes.
16. Add server transport adapter and friend join boundary.
17. Add handshake and input/snapshot message handling models.
18. Add client match connection skeleton sufficient for local/friend play.
19. Add input sampler and snapshot interpolation/presentation.
20. Add main menu, mode select, HUD, pause menu, loading state, and result screen.
21. Add local backend adapter/Nakama-compatible boundary.
22. Add tests or command checks for implemented subsystems.
23. Run all available validation commands.
24. Report exact files changed, commands run, failures, retry log, and limitations.

## Acceptance gates

A one-prompt attempt is successful only when these gates pass or are explicitly blocked by missing external tooling:

### Gate 1 - Complete game loop

- Launch path exists.
- Menu-to-mode-select-to-match-to-result flow exists.
- Player can start either required mode without manual editor work.
- Bot-filled slots make both modes playable.
- Matches end by score limit or timer.

### Gate 2 - Repository coherence

- The layout matches `24_exact_repository_layout.md`, or `docs/PROJECT_LAYOUT_MAPPING.md` explains the mapping.
- No duplicate alternative architecture exists.
- Old v1 docs are not used as the source of truth.

### Gate 3 - Content validation

- Seed content loads from JSON.
- At least 3 heroes and 9 abilities exist.
- Both required modes exist as data.
- Duplicate IDs fail validation.
- Missing hero/ability/map/mode references fail validation.
- `validate-content` exits non-zero on invalid content when CLI execution is available.

### Gate 4 - Protocol model

- Envelopes include protocol version, message type, sequence, ticks, IDs, timestamp, and payload.
- Input frames clamp or reject invalid movement and aim values.
- Codec round trip is covered by tests or a command check.

### Gate 5 - Simulation

- The server simulation owns authoritative position, health, cooldowns, damage, deaths, score/rank, and match end.
- `SimulationWorld.step_tick()` advances exactly one fixed tick.
- Client presentation scripts do not decide authoritative outcomes.

### Gate 6 - Bots

- Bots submit `InputFrame` through the same path as players.
- Bot difficulty is data-driven.
- Bot-only 3v3 and 25-player deathmatch can start, run, and finish headlessly when the runtime supports it.

### Gate 7 - UI/playability/art

- Main menu exists.
- Mode select exists.
- HUD exists.
- Pause/escape menu exists.
- Result screen exists.
- Heroes, abilities, VFX, arena, scoreboard/ranking, and screens follow `CODEX_ART_DIRECTION.md`.
- The minimum player path does not require manual scene wiring after Codex finishes.

### Gate 8 - Multiplayer/backend boundary

- Server transport is isolated behind an adapter.
- Friend join path exists through LAN/IP, room code, dev token, or local adapter.
- Handshake, join, input, ack, snapshot, event batch, and correction message models exist.
- Gameplay code does not directly depend on a concrete socket implementation.
- Local backend adapter follows the Nakama contract and does not pretend to be production integration.

### Gate 9 - Debuggability

- `DebugBus` exists.
- Match ID, player ID, entity ID, server tick, and event type are included in relevant logs.
- Bot soak output includes mode, match count, participant count, errors, average duration, and failure summaries.

### Gate 10 - Honest report

The final response must include:

- files changed,
- commands run,
- failed commands and fixes attempted,
- commands unavailable because of missing Godot/Nakama/tooling,
- validation results,
- known limitations,
- whether the game is runnable in the current environment,
- next highest-value task if anything remains.

## Failure recovery rules

If Godot is unavailable in the execution environment, still create valid text files and scripts, then run available static checks such as JSON parsing and repository file inspection.

If Nakama cannot run, add local Docker/config files and a local backend adapter using the same interface. Do not fake successful live Nakama integration.

If a scene cannot be safely edited as text, prefer creating minimal text-safe scenes for the required game loop. If that is impossible, create the script and document the required scene wiring in `docs/SCENE_WIRING_NOTES.md`, then report that the no-manual-work gate is not fully satisfied.

If a task becomes too large, preserve the architecture and complete the next smallest coherent complete-game path. Do not switch to a disconnected prototype.

## Forbidden shortcuts

Do not:

- trust client damage, kills, cooldown completion, rewards, rank, inventory, or match result,
- hard-code hero or ability tuning inside gameplay scripts except test fixtures,
- put gameplay authority in UI scripts,
- create a second protocol model outside the agreed network classes,
- add a local-only combat path that bypasses `InputFrame` and server simulation,
- add secret keys to client code or committed config,
- remove acceptance checks to make the task appear complete,
- label unfinished systems as complete,
- ask the user to manually finish the required game path.

## Final report format

End the run with this format:

```text
Summary:
- ...

Game completion status:
- Complete / incomplete, with reason

Files changed:
- ...

Commands run:
- ...

Retry log:
- command -> failure -> fix -> rerun result

Validation:
- ...

Blocked/unavailable:
- ...

Known limitations:
- ...

Next task:
- ...
```
