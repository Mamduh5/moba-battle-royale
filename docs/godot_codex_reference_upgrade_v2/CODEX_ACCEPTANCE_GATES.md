# Codex Acceptance Gates

This file exists so a coding agent can judge complete-game progress without inventing its own completion criteria.

## Minimum successful complete game

The one-prompt build is acceptable when the repository supports this local player-facing flow:

```text
launch game -> main menu -> start match -> hero assigned/selected -> arena loads -> player and bots spawn -> 3v3 match plays -> match ends by score/timer -> result screen -> restart or return to menu
```

It must also support this automated headless flow:

```text
load content -> validate content -> start authoritative match room -> bots submit input frames -> simulation advances ticks -> snapshots are built -> match finishes -> result object is produced -> bot-soak summary is printed
```

Client, transport, and backend may use local development adapters if external services are unavailable, but their interfaces must match the final architecture.

## Required gates

### 1. Complete game loop gate

- `project.godot` exists or the repo has an equivalent documented Godot project root.
- A launch scene exists.
- Main menu exists.
- Match start path exists.
- Player hero assignment or selection exists.
- Arena scene exists.
- HUD exists.
- Pause/escape menu exists.
- Result screen exists.
- Restart or return-to-menu path exists.
- The required game path does not depend on the user manually wiring scenes after Codex finishes.

### 2. Architecture gate

- `docs/CODEX.md` exists.
- `docs/godot_codex_reference_upgrade_v2/CODEX_ONE_PROMPT_BUILD.md` exists.
- `docs/godot_codex_reference_upgrade_v2/CODEX_COMPLETE_GAME_CONTRACT.md` exists.
- `docs/godot_codex_reference/` is removed and must not be recreated.
- The implementation follows `Godot client -> Godot headless match server -> Nakama-compatible backend boundary`.
- No separate local-only architecture is introduced.

### 3. Layout gate

- Required folders from `24_exact_repository_layout.md` exist or are mapped in `docs/PROJECT_LAYOUT_MAPPING.md`.
- New gameplay scripts live under `shared/`, `client/`, `server/`, or `tools/cli/` according to ownership.
- UI scripts do not own combat truth.

### 4. Data gate

- At least 3 heroes exist as JSON.
- At least 9 abilities exist as JSON.
- One mode, one map, and one bot profile exist as JSON.
- Runtime scripts read tuning from data rather than hard-coded constants.
- Content validation rejects duplicates and broken references.

### 5. Protocol gate

- `NetworkEnvelope`, `InputFrame`, `SnapshotFrame`, and `NetworkCodec` exist.
- Input is sequence-numbered.
- Server snapshots include authoritative tick and last processed input information.
- Invalid protocol versions are rejected or explicitly marked as a failing test.

### 6. Simulation gate

- `SimulationWorld.step_tick()` is the main authoritative tick entrypoint.
- Movement, health, damage, death, respawn, cooldowns, abilities, scoring, and match completion are server-owned.
- Match ends by score limit or timer.
- The simulation can run without Godot editor UI.

### 7. Bot gate

- Bots use the same `InputFrame` pathway as players.
- Bot profile tuning is data-driven.
- Bots can move, attack, use abilities, retreat, and pursue the score objective.
- A bot-only 3v3 match can be run from a headless command or documented command path.

### 8. UI/playability gate

- Player can understand health, cooldowns, score, timer, and match state.
- Visual presentation is simple but coherent.
- Required player-facing screens do not call the game a mockup, prototype, demo, placeholder, or unfinished build.
- No required minimum-game interaction is left as an instruction for the user to complete manually.

### 9. Debug gate

- `DebugBus` exists.
- Logs include match ID, player ID, entity ID where relevant, tick, event type, and error details.
- Bot soak and protocol checks report failure summaries.

### 10. Test/command gate

At minimum, add command paths for:

```text
validate-content
protocol-check
bot-soak
run-tests
```

If the runtime cannot execute them in the current environment, the scripts and command router still need to exist, and the final report must state what could not be executed.

### 11. Report gate

The agent must end with a factual report. Do not claim a command passed if it was not run. The report must state whether the complete-game target was met.

## What does not count as success

- A single offline combat scene with no server boundary.
- A movement demo.
- A partial vertical slice missing menus, bots, HUD, match end, or result screen.
- Bots that directly mutate simulation state instead of submitting input frames.
- Client-side damage, cooldowns, kills, score, or match result as trusted truth.
- Seed content hard-coded in scripts.
- Nakama functionality faked as complete without a local stack, local adapter, or explicit boundary.
- Scene/UI polish without content validation and authoritative simulation.
- A final answer that asks the user to manually finish required game-path wiring.
