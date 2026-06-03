# Codex One-Prompt Build Mission

This file is the controlling instruction for a coding agent attempting to build a coherent first vertical slice from one prompt.

Do not brainstorm. Do not redesign the stack. Do not create an unrelated demo. Implement the first playable full-stack vertical slice inside the existing repository while preserving the final architecture.

## Required reading order

Read these files before editing:

1. `docs/CODEX.md`
2. `docs/godot_codex_reference_upgrade_v2/CODEX_BUILD_CONTRACT.md`
3. `docs/godot_codex_reference_upgrade_v2/docs/24_exact_repository_layout.md`
4. `docs/godot_codex_reference_upgrade_v2/docs/25_godot_class_contracts.md`
5. `docs/godot_codex_reference_upgrade_v2/docs/26_cli_command_contract.md`
6. `docs/godot_codex_reference_upgrade_v2/docs/27_network_payload_contracts.md`
7. `docs/godot_codex_reference_upgrade_v2/docs/28_nakama_runtime_contract.md`
8. `docs/godot_codex_reference_upgrade_v2/docs/33_testing_contract.md`
9. `docs/godot_codex_reference_upgrade_v2/docs/34_bot_contracts.md`
10. `docs/godot_codex_reference_upgrade_v2/docs/35_scene_ui_contracts.md`

Use `docs/godot_codex_reference_upgrade_v2/docs/30_first_30_codex_tasks.md` as the build order, but apply the scope limits in this file.

## Build target

Implement the first production-shaped local vertical slice:

```text
Godot client -> Godot headless authoritative match server -> local Nakama contract/stub boundary
```

The vertical slice must include:

- repository layout from the exact layout contract,
- required autoload skeletons,
- typed GDScript core classes,
- content JSON for one hero, at least three abilities, one 3v3 mode, one arena map, and one bot profile,
- content loader and validator,
- CLI command router,
- network envelope, input frame, snapshot frame, and codec,
- simulation state and fixed-tick simulation world,
- movement, health, damage, cooldown, and at least one basic ability path,
- authoritative match room with bot-only local match support,
- bots submitting the same `InputFrame` objects as human players,
- local server transport abstraction,
- protocol handshake message models,
- input/snapshot loop models,
- client connection state machine skeleton,
- input sampler skeleton,
- snapshot presentation boundary,
- HUD state facade boundary,
- Nakama local Docker/config contract or stub module with clear TODO gates,
- validation, parse, protocol, and bot-soak commands where feasible,
- structured debug logs through `DebugBus`.

## Hard stop scope

Do not attempt to finish the entire commercial game in one pass.

Do not implement:

- ranked matchmaking,
- cosmetics economy,
- real-money purchases,
- multiple heroes beyond the seed content,
- complex map art,
- final mobile UI polish,
- production deployment automation,
- advanced anti-cheat,
- complete reconnect support,
- full replay tooling,
- all MOBA lane systems.

Create extension points for those systems only when the contract requires them.

## Implementation order

Work in this order. Do not skip ahead to visual polish.

1. Inspect the existing repository.
2. Create or map the exact repository layout.
3. Add `docs/PROJECT_LAYOUT_MAPPING.md` if any existing structure differs from the contract.
4. Add autoload scripts and document required `project.godot` autoload entries.
5. Add content examples into real `res://content/` paths.
6. Add content loader and validator.
7. Add CLI command router and `validate-content` command.
8. Add protocol models and codec.
9. Add simulation state, clock, config, and entity registry.
10. Add movement, health, damage, death, cooldown, and ability runtime minimums.
11. Add `SimulationWorld.step_tick()`.
12. Add `MatchRoom` and bot-only match lifecycle.
13. Add bot perception/brain/input builder minimums.
14. Add `bot-soak` command.
15. Add server transport adapter boundary.
16. Add handshake and input/snapshot message handling models.
17. Add client match connection skeleton.
18. Add input sampler and snapshot interpolation skeletons.
19. Add HUD state facade boundary.
20. Add Nakama local config/stub boundary.
21. Add tests or command checks for each implemented subsystem.
22. Run all available validation commands.
23. Report exact files changed, commands run, failures, and deferred items.

## Acceptance gates

A one-prompt attempt is successful when these gates pass or are explicitly blocked by missing external tooling:

### Gate 1 - Repository coherence

- The layout matches `24_exact_repository_layout.md`, or `docs/PROJECT_LAYOUT_MAPPING.md` explains the mapping.
- No duplicate alternative architecture exists.
- v1 docs are not used as the source of truth.

### Gate 2 - Content validation

- Seed content loads from JSON.
- Duplicate IDs fail validation.
- Missing hero/ability/map/mode references fail validation.
- `validate-content` exits non-zero on invalid content when CLI execution is available.

### Gate 3 - Protocol model

- Envelopes include protocol version, message type, sequence, ticks, IDs, timestamp, and payload.
- Input frames clamp or reject invalid movement and aim values.
- Codec round trip is covered by tests or a command check.

### Gate 4 - Simulation

- The server simulation owns authoritative position, health, cooldowns, damage, deaths, score, and match end.
- `SimulationWorld.step_tick()` advances exactly one fixed tick.
- Client presentation scripts do not decide authoritative outcomes.

### Gate 5 - Bots

- Bots submit `InputFrame` through the same path as players.
- Bot difficulty is data-driven.
- Bot-only local match can start, run, and finish headlessly when the runtime supports it.

### Gate 6 - Multiplayer boundary

- Server transport is isolated behind an adapter.
- Handshake, join, input, ack, snapshot, event batch, and correction message models exist.
- Gameplay code does not directly depend on a concrete socket implementation.

### Gate 7 - Debuggability

- `DebugBus` exists.
- Match ID, player ID, entity ID, server tick, and event type are included in relevant logs.
- Bot soak output includes match count, errors, average duration, and failure summaries.

### Gate 8 - Honest report

The final response must include:

- files changed,
- commands run,
- commands unavailable because of missing Godot/Nakama/tooling,
- validation results,
- known limitations,
- next highest-value task.

## Failure recovery rules

If Godot is unavailable in the execution environment, still create valid text files and scripts, then run available static checks such as JSON parsing and repository file inspection.

If Nakama cannot run, add local Docker/config files and a stubbed integration boundary. Do not fake successful backend integration.

If a scene cannot be safely edited as text, create the script and document the required scene wiring in `docs/SCENE_WIRING_NOTES.md`.

If a task becomes too large, preserve the architecture and complete the next smallest coherent slice. Do not switch to a disconnected prototype.

## Forbidden shortcuts

Do not:

- trust client damage, kills, cooldown completion, rewards, rank, inventory, or match result,
- hard-code hero or ability tuning inside gameplay scripts except test fixtures,
- put gameplay authority in UI scripts,
- create a second protocol model outside the agreed network classes,
- add a local-only combat path that bypasses `InputFrame` and server simulation,
- add secret keys to client code or committed config,
- remove acceptance checks to make the task appear complete.

## Final report format

End the run with this format:

```text
Summary:
- ...

Files changed:
- ...

Commands run:
- ...

Validation:
- ...

Blocked/unavailable:
- ...

Known limitations:
- ...

Next task:
- ...
```
