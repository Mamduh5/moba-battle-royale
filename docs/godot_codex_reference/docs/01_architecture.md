# Architecture

## System boundary

The project has four major runtime areas:

1. Client app.
2. Dedicated match server.
3. Nakama backend.
4. Tooling and QA utilities.

The client presents the game and collects player input. The match server owns real-time gameplay. Nakama owns identity, matchmaking, persistent player data, social data, and meta-game services. Tooling verifies data, reproduces bugs, runs simulations, and supports releases.

## Repository layout

Use this structure:

```text
addons/                         # third-party Godot plugins, pinned and documented
assets/                         # imported art/audio/source assets
client/                         # client-only scenes/scripts
content/                        # reviewed gameplay data
content/heroes/
content/abilities/
content/items/
content/maps/
content/modes/
docs/codex_reference/           # this pack
server/                         # dedicated match server scenes/scripts
shared/                         # server/client gameplay code with no UI dependency
tests/                          # unit, simulation, replay, integration tests
tools/                          # validation scripts, replay tools, export helpers
infra/                          # local/staging/prod service config
project.godot
export_presets.cfg
```

## Runtime layers

### Client layer

Responsibilities:

- Capture input.
- Render world state.
- Interpolate snapshots.
- Predict local movement where permitted.
- Display UI, VFX, audio, camera, and feedback.
- Connect to Nakama for auth and meta systems.
- Connect to match server for active gameplay.

The client does not own hit confirmation, damage, cooldowns, rewards, or match outcome.

### Shared gameplay layer

Responsibilities:

- Data loading.
- Entity definitions.
- Combat formulas.
- Ability behavior modules.
- Status effect definitions.
- Team/targeting rules.
- Math utilities.
- Serialization helpers.
- Event definitions.

Shared gameplay code must not import client UI, audio, VFX, camera, or input nodes.

### Server layer

Responsibilities:

- Match lifecycle.
- Player admission and token validation.
- Authoritative simulation loop.
- Input validation.
- Entity spawning and despawning.
- Bot hosting.
- Snapshot generation.
- Reconnect and disconnect policy.
- Match result signing and submission.

### Backend bridge layer

Responsibilities:

- Nakama session creation and refresh.
- Matchmaker tickets.
- Party/lobby state.
- Player profile retrieval.
- Inventory/progression reads.
- Match result writeback.
- Live configuration fetch.
- Backend error mapping.

## Dependency rule

Allowed dependencies:

```text
client -> shared
client -> backend_bridge
client -> network_client
server -> shared
server -> backend_bridge_server
qa_tools -> shared
qa_tools -> server
```

Forbidden dependencies:

```text
shared -> client
shared -> server scene tree assumptions
server -> client UI
backend_bridge -> client UI
content data -> scene-only magic names without validation
```

## Autoloads

Use autoloads sparingly. Recommended autoloads:

- `AppConfig`: environment, build, feature flags.
- `Log`: structured logging wrapper.
- `EventBus`: client-local presentation events only.
- `ServiceLocator`: references to runtime services after boot.
- `ContentRegistry`: validated access to loaded data.

Do not put large gameplay state in global singletons. Match state belongs to match runtime nodes.

## Scene ownership

Client scene tree:

```text
ClientRoot
  Boot
  AuthFlow
  LobbyFlow
  MatchClientRoot
    WorldView
    EntityViews
    HudLayer
    CameraRig
    AudioLayer
    VfxLayer
```

Server scene tree:

```text
ServerRoot
  MatchRuntime
    SimulationClock
    EntityRegistry
    PlayerRegistry
    BotDirector
    ObjectiveDirector
    SnapshotBroadcaster
```

The client visual entity and server simulation entity are separate concepts linked by stable entity ID.
