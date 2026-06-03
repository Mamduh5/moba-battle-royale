# 30 - First 30 Codex Tasks

Execute these in order. Do not skip to UI polish before the simulation, content validation, and server tick loop exist.

Each task must end with changed files, commands run, validation result, and notes.

## Foundation

### Task 01 - Create repository layout

Create missing folders from `24_exact_repository_layout.md`. Add placeholder `.gitkeep` files only where required.

Acceptance:

- Layout exists.
- No gameplay code yet except minimal README files if needed.

### Task 02 - Add autoload skeletons

Create `GameConfig`, `ContentDB`, `DebugBus`, and `Protocol`.

Acceptance:

- Scripts parse.
- Autoload names are documented for `project.godot`.
- No large gameplay logic inside autoloads.

### Task 03 - Add content examples

Copy example content into `res://content/` or create equivalent real content.

Acceptance:

- One hero, three abilities minimum, one mode, one map, one bot profile.

### Task 04 - Implement content loader

Implement `ContentLoader`, `ContentValidator`, and data def classes.

Acceptance:

- Loads all JSON.
- Validates references.
- Fails on duplicate IDs.

### Task 05 - Implement CLI command router

Implement `HeadlessCommandRouter.gd` and `validate-content`.

Acceptance:

- Real command runs from terminal.
- Invalid content returns non-zero exit code.

## Simulation

### Task 06 - Implement network models

Implement `NetworkEnvelope`, `InputFrame`, `SnapshotFrame`, and `NetworkCodec`.

Acceptance:

- Encode/decode round trip tests pass.
- Invalid envelope rejected.

### Task 07 - Implement simulation state

Implement `SimulationState`, `EntityRegistry`, `SimulationClock`, and `SimulationConfig`.

Acceptance:

- Entities can be created, patched, removed, queried.
- Events can be pushed/drained.

### Task 08 - Implement movement motor

Implement movement from input frames.

Acceptance:

- Movement clamps speed.
- Movement rejects NaN/infinite input.
- Unit tests cover diagonal movement normalization.

### Task 09 - Implement health and damage

Implement `DamageRequest`, `DamageResult`, `HealthComponent`, `DamageResolver`, and `DeathResolver`.

Acceptance:

- Damage cannot affect dead entities.
- Friendly-fire rule follows mode config.
- Death event emitted once.

### Task 10 - Implement cooldowns and ability runtime

Implement cast validation, cooldowns, basic attack, and one dash or projectile.

Acceptance:

- Server accepts valid cast.
- Server rejects cooldown/range/invalid target.
- Cooldown starts only after accepted cast.

### Task 11 - Implement objective and victory services

Implement score service and victory resolver for team arena.

Acceptance:

- Match finishes by score limit or timer.

### Task 12 - Implement `SimulationWorld.step_tick()`

Wire input, movement, abilities, damage, objectives, deaths, respawns, and snapshots.

Acceptance:

- Headless simulation can run 10,000 ticks without crash.

## Server

### Task 13 - Implement `MatchRoom`

Create room lifecycle with player slots, teams, simulation world, and tick loop.

Acceptance:

- Local bot-only match can start and finish.

### Task 14 - Implement `ServerBotManager`

Bots fill empty slots and submit input frames.

Acceptance:

- Bots use same `receive_input()` path as players.

### Task 15 - Implement bot perception and brain

Create simple objective/target/ability scoring.

Acceptance:

- Bots move, attack, retreat at low health, and pursue objectives.

### Task 16 - Implement `bot-soak` command

Run repeated matches headlessly.

Acceptance:

- Summary output includes match count, errors, average duration.

### Task 17 - Implement server transport adapter

Add WebSocket or ENet adapter behind `ServerTransport`.

Acceptance:

- Transport can accept connection locally.
- Gameplay code does not import transport class directly.

### Task 18 - Implement protocol handshake

Add `client_hello`, `server_welcome`, `join_match`, `join_accepted`, `join_rejected`.

Acceptance:

- Invalid protocol version rejected.

### Task 19 - Implement input/snapshot loop

Add `player_input`, `input_ack`, `world_snapshot`, `combat_event_batch`.

Acceptance:

- One local client can connect, send input, receive snapshots.

### Task 20 - Implement correction messages

Add server correction and client reconciliation stubs.

Acceptance:

- Client can apply authoritative correction without crashing.

## Client

### Task 21 - Implement client app and match client

Build connection state machine and message dispatch.

Acceptance:

- Client can connect to local server with dev token.

### Task 22 - Implement input sampler

Keyboard/mouse first, mobile adapter second.

Acceptance:

- InputFrame values clamp and sequence increments.

### Task 23 - Implement snapshot interpolation

Render entities from snapshots without mutating simulation state.

Acceptance:

- Entity presentation spawns/despawns from snapshots.

### Task 24 - Implement prediction buffer

Store local input and predicted state for local player.

Acceptance:

- Can replay after correction for local movement.

### Task 25 - Implement HUD bindings

Show health, cooldowns, score, timer, ping, and connection state.

Acceptance:

- HUD reads client state facade only.

## Backend

### Task 26 - Add Nakama local Docker stack

Create local compose and env example.

Acceptance:

- Nakama starts locally.
- Secrets are not committed.

### Task 27 - Add Nakama profile/loadout RPCs

Implement profile read and loadout save.

Acceptance:

- Client can fetch profile from Nakama in local dev.

### Task 28 - Add matchmaking/token RPCs

Implement match ticket, cancellation, and match token issuing.

Acceptance:

- Token includes match/player/team/hero/expiry claims.

### Task 29 - Add result submission RPC

Match server submits result to Nakama.

Acceptance:

- Nakama rejects client calls and duplicate match results.

## Integration

### Task 30 - End-to-end local match

Run local Nakama, local headless match server, and one client with bots.

Acceptance:

- Client logs in.
- Client enters match.
- Bots fill empty slots.
- Match starts, runs, finishes.
- Result is submitted to Nakama.
- Client returns to result screen.
- Logs contain match ID, server tick range, result, and errors count.
