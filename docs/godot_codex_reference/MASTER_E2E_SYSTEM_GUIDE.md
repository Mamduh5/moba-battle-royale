# Master End-to-End System Guide

This guide defines the full target system for a Godot 4.x top-down hero arena / MOBA-lite game. The project is built for mobile-first controls, online PvP, bots, live backend services, deterministic debugging, and code-agent-assisted development.

## 1. Product target

Build a competitive top-down hero combat game with short-session arena matches, tactical abilities, team objectives, ranked and unranked matchmaking, bots, reconnect support, progression, account-backed inventory, and production-ready debugging tools.

The game supports the following match types:

- Team arena: 2v2 and 3v3.
- Objective arena: capture point, crystal push, escort, or neutral boss objective.
- MOBA-lite lane mode: towers, minions, jungle camps, base objective.
- Training mode: local solo practice against bots using the same combat systems.
- Custom room: private match with configurable map, mode, team size, bots, and ruleset.

The first playable path may expose fewer modes, but the architecture must already support the complete set. Do not build separate one-off systems for early playable screens.

## 2. Technology stack

Use Godot 4.x for the client and for the dedicated match server. Use typed GDScript for normal gameplay. Use C# only for isolated modules that require stronger type tooling or external libraries. Use GDExtension only for performance-critical native code after profiling proves the need.

Use Nakama for account and meta-service capabilities:

- Device, email, and optional platform authentication.
- Session validation.
- Matchmaking tickets.
- Party/lobby coordination.
- Friends, chat, and social presence.
- Player storage, inventory metadata, cosmetics, currencies, and progression.
- Leaderboards, ranked seasons, daily missions, and server-driven configuration.

Use a Godot headless dedicated server for real-time simulation authority. Nakama coordinates player identity and match allocation. Combat truth remains in the match server.

## 3. Runtime topology

```text
Mobile/Desktop Client
  | auth/session/socket/meta
  v
Nakama Backend
  | match allocation, player ticket, session verification
  v
Godot Dedicated Match Server
  | authoritative simulation snapshots
  v
Connected Clients
```

The client connects to Nakama for identity and meta systems. Matchmaking returns a match assignment. The client then connects to the dedicated match server using a short-lived signed match token. The match server validates token claims before admitting the player.

## 4. Trust model

The client is an input terminal and presentation layer. The server is the arbiter of gameplay truth.

The client may send:

- Movement input vector.
- Aim vector or aim target.
- Ability cast request.
- Item/action request.
- Emote/ping request.
- Client timing metadata.

The client may not send trusted values for:

- Position as final truth.
- Damage dealt.
- Hit confirmation.
- Cooldown completion.
- Health, mana, shields, resources.
- Kill/death/assist status.
- Match result.
- Currency, rank, inventory, reward claims.

## 5. Simulation model

The match server runs the authoritative simulation at a fixed tick rate. Target 30 ticks per second for gameplay simulation. Snapshot delivery may run at 10 to 20 snapshots per second depending on bandwidth budget. Clients render interpolated snapshots and predict only local movement where safe.

Use stable entity IDs. Use deterministic event names. Use a single authoritative match clock. All gameplay events include match time, server tick, entity IDs, source IDs, target IDs, and correlation IDs when triggered by player input.

## 6. Code architecture

Separate the project into these layers:

```text
client_presentation/     # camera, UI, input widgets, audio, VFX, local settings
shared_gameplay/         # rules, data loading, combat formulas, entity components
match_server/            # authoritative runtime, validation, snapshots, bot brain hosting
backend_bridge/          # Nakama auth, matchmaking, storage, telemetry, live config
content_data/            # heroes, abilities, items, map rules, tuning tables
qa_tools/                # replay runner, bot soak, fixtures, debug overlays
```

Client and server may share pure gameplay definitions and data parsers. They must not share presentation-only scripts.

## 7. Data-driven content

Heroes, abilities, items, status effects, map objectives, minions, jungle camps, towers, and game modes must be defined as data first. Scripts implement generic runtime behavior. Data files select behavior modules and tuning values.

Use schemas from `schemas/` to validate content. A hero data file is invalid if an ability reference, animation key, icon key, tuning field, or server behavior ID is missing.

## 8. Gameplay systems

Core systems:

- Entity lifecycle.
- Movement and collision.
- Combat resources.
- Health, damage, shields, healing, and death.
- Abilities and cooldowns.
- Projectiles, hit scans, area effects, traps, summons, and persistent zones.
- Status effects.
- Team rules and target filtering.
- Objective scoring.
- Spawn, respawn, and invulnerability windows.
- Fog/visibility if enabled by mode.
- Rewards and post-match reporting.

Each system exposes server APIs, client prediction hooks where required, replay events, debug inspectors, and tests.

## 9. Multiplayer systems

Implement a server-authoritative network protocol with input commands from clients and state snapshots from the server.

Required features:

- Player authentication through match token.
- Player join, ready, load-complete, and spawn handshake.
- Input sequence numbers and acknowledgements.
- Server validation and correction.
- Client-side interpolation.
- Local movement prediction with reconciliation.
- Ability cast request validation.
- Snapshot compression and interest management.
- Reconnect within match timeout.
- Spectator/admin observer mode.
- Bot fill for missing players.
- Match result submission to backend.

## 10. Bots

Bots are production participants, not debug-only actors. Bots use the same input-command pathway as human players. A bot brain chooses intent, then submits movement and ability commands. The simulation resolves outcomes normally.

Bot difficulty is data-driven. Difficulty changes decision frequency, reaction delay, aim error, retreat thresholds, objective priority, and team coordination, but not private access to forbidden gameplay outcomes.

## 11. Debugging and observability

Every multiplayer problem must be diagnosable after the match. Implement:

- Client debug overlay.
- Server match log.
- Structured event stream.
- Snapshot inspector.
- Input history buffer.
- Replay capture and replay runner.
- Network metrics: RTT, packet loss, snapshot delay, reconciliation count.
- Bot decision logging.
- Backend request logging with correlation IDs.

## 12. Build and deployment

Local development runs with Godot editor, Godot headless server, and local Nakama through Docker Compose. Staging and production use the same service boundaries. Do not build a separate offline-only branch of the architecture.

Required commands are documented in `docs/12_build_run_export.md` and `scripts/`.

## 13. Testing

Tests include:

- Unit tests for formulas and data validation.
- Headless server simulation tests.
- Replay determinism tests.
- Network message contract tests.
- Bot-vs-bot soak tests.
- Load tests for match server capacity.
- Mobile input manual tests.
- Backend integration tests against local Nakama.

A merge is not ready when gameplay only works from a manual editor run.

## 14. Release discipline

Every release candidate must pass the release checklist. Match logic, data, and backend configuration must be versioned. Clients must refuse to join incompatible match server versions. Live configuration must include safe defaults and server-side validation.
