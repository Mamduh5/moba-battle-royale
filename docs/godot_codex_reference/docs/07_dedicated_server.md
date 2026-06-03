# Dedicated Match Server

## Server process

Run the match server as a Godot headless export. The server starts with explicit CLI parameters:

```text
godot --headless --path . --server   --port 24560   --match-id match_abc   --mode mode_team_arena_3v3   --map map_sunken_arena   --backend-url http://127.0.0.1:7350   --env local
```

Use project scripts to parse arguments into `ServerConfig`.

## Server lifecycle

1. Boot server process.
2. Load environment config.
3. Load and validate content manifest.
4. Connect to backend if required.
5. Register match availability or accept assigned match payload.
6. Wait for player admission.
7. Run match warmup.
8. Start authoritative simulation.
9. Produce match result.
10. Submit result to backend.
11. Flush logs/replay.
12. Exit or return to pool.

## Match admission

A player may join only when:

- match ID matches token.
- token signature is valid.
- token is not expired.
- player ID is in roster or allowed as spectator/admin.
- client build and content manifest are compatible.
- duplicate session policy is resolved.

## Process isolation

One process may host one match during initial scale. Multi-match process hosting is allowed only after profiling and operational tooling are ready. Keep the match runtime independent so both modes are possible.

## Runtime services

Server services:

- `ServerConfig`
- `MatchClock`
- `PlayerRegistry`
- `EntityRegistry`
- `CommandQueue`
- `SimulationRunner`
- `BotDirector`
- `SnapshotService`
- `ReplayRecorder`
- `BackendResultSubmitter`
- `AdminCommandService`

## Crash handling

Server writes periodic match state and event log checkpoints. On crash, the coordinator marks the match failed or attempts recovery according to mode policy. Ranked matches need explicit result policy for failed servers.

## Administrative commands

Admin commands require signed admin authorization. Supported commands:

- inspect entity
- inspect player
- force end match
- pause custom match
- spawn bot in custom match
- dump replay buffer
- set debug verbosity

Admin commands are logged.
