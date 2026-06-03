# Start Here

Use this folder as the project contract. Follow these files before editing gameplay, networking, bots, UI integration, backend integration, or build scripts.

## Working mode

Make changes that move the project toward the documented final architecture. Keep commits small, reviewable, and safe. Do not create throwaway systems that will be replaced by a different architecture later.

## Required reading before edits

Read the relevant files before editing:

- Any gameplay change: `docs/02_gameplay_systems.md`, `docs/03_combat_abilities.md`, `docs/04_data_contracts.md`.
- Any multiplayer change: `docs/05_multiplayer_authority.md`, `docs/06_network_protocol.md`, `docs/07_dedicated_server.md`.
- Any backend change: `docs/08_nakama_backend.md`, `docs/09_matchmaking_lobby_progression.md`.
- Any bot change: `docs/10_bots_ai.md`.
- Any build or deploy change: `docs/12_build_run_export.md`, `infra/README.md`.
- Any debugging, logging, or test change: `docs/13_debug_observability.md`, `docs/14_testing_qa.md`.

## Edit policy

Use typed GDScript for gameplay code unless a file is already in another language. Keep scripts focused. Prefer data-driven definitions for heroes, abilities, map objectives, items, and game-mode tuning.

Never place real gameplay authority inside UI scripts. UI scripts can display state and emit input intent. Simulation scripts decide outcomes.

Never let the client report damage, kills, cooldown completion, rewards, currency, rank, inventory, or final score as trusted facts. Treat all client messages as requests.

## Scene policy

Scene edits are allowed only when the change is small and text-reviewable. For complex UI layout, animation setup, imported assets, collision authoring, or visual hierarchy changes, update the relevant task note and leave the scene work for the Godot editor.

## Task completion rule

A change is complete only when it includes:

- Implementation code.
- Updated data contracts if data shape changed.
- Updated docs if architecture or behavior changed.
- Tests or a documented manual verification path.
- Debug output or inspection support for runtime diagnosis.
- No new production-path stubs.
