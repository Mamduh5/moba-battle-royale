# Codex Acceptance Gates

This file exists so a coding agent can judge progress without inventing its own completion criteria.

## Minimum successful vertical slice

The first build is acceptable when it produces a repository that can support this local flow:

```text
load content -> validate content -> start authoritative match room -> bots submit input frames -> simulation advances ticks -> snapshots are built -> match finishes -> result object is produced
```

Client, transport, Nakama, and UI may be partially skeletal in the first pass, but their boundaries must be real and compatible with the final architecture.

## Required gates

### 1. Architecture gate

- `docs/CODEX.md` exists.
- `docs/godot_codex_reference_upgrade_v2/CODEX_ONE_PROMPT_BUILD.md` exists.
- `docs/godot_codex_reference/` is deprecated and not referenced as the active build contract.
- The implementation follows `Godot client -> Godot headless match server -> Nakama`.
- No separate local-only architecture is introduced.

### 2. Layout gate

- Required folders from `24_exact_repository_layout.md` exist or are mapped in `docs/PROJECT_LAYOUT_MAPPING.md`.
- New gameplay scripts live under `shared/`, `client/`, `server/`, or `tools/cli/` according to ownership.
- UI scripts do not own combat truth.

### 3. Data gate

- Hero, ability, mode, map, and bot data exist as JSON.
- Runtime scripts read tuning from data rather than hard-coded constants.
- Content validation rejects duplicates and broken references.

### 4. Protocol gate

- `NetworkEnvelope`, `InputFrame`, `SnapshotFrame`, and `NetworkCodec` exist.
- Input is sequence-numbered.
- Server snapshots include authoritative tick and last processed input information.
- Invalid protocol versions are rejected or explicitly marked as a failing test.

### 5. Simulation gate

- `SimulationWorld.step_tick()` is the main authoritative tick entrypoint.
- Movement, health, damage, death, cooldowns, abilities, scoring, and match completion are server-owned.
- The simulation can run without Godot editor UI.

### 6. Bot gate

- Bots use the same `InputFrame` pathway as players.
- Bot profile tuning is data-driven.
- A bot-only match can be run from a headless command or documented command path.

### 7. Debug gate

- `DebugBus` exists.
- Logs include match ID, player ID, entity ID where relevant, tick, event type, and error details.
- Bot soak and protocol checks report failure summaries.

### 8. Test/command gate

At minimum, add command paths for:

```text
validate-content
protocol-check
bot-soak
run-tests
```

If the runtime cannot execute them in the current environment, the scripts and command router still need to exist, and the final report must state what could not be executed.

### 9. Report gate

The agent must end with a factual report. Do not claim a command passed if it was not run.

## What does not count as success

- A single offline combat scene with no server boundary.
- Bots that directly mutate simulation state instead of submitting input frames.
- Client-side damage, cooldowns, kills, score, or match result as trusted truth.
- Seed content hard-coded in scripts.
- Nakama functionality faked as complete without a local stack or explicit stub boundary.
- Scene/UI polish without content validation and authoritative simulation.
