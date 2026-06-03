# Build, Run, and Export

## Local prerequisites

Install:

- Godot 4.x pinned for the project.
- Export templates matching the pinned Godot version.
- Docker and Docker Compose for Nakama local services.
- Git.
- Optional: VS Code with Godot/GDScript extensions.

## Local commands

Run client from editor for normal development.

Run server headless:

```bash
godot --headless --path . --server --port 24560 --env local --mode mode_team_arena_3v3 --map map_sunken_arena
```

Run tests:

```bash
godot --headless --path . --run-tests
```

Run content validation:

```bash
godot --headless --path . --validate-content
```

Run bot soak:

```bash
godot --headless --path . --bot-soak --matches 100 --mode mode_team_arena_3v3
```

The exact commands may be wrapped by scripts after the repository creates the entry points. Keep CLI arguments stable and documented.

## Export presets

Create export presets for:

- Android client debug.
- Android client release.
- Desktop client debug.
- Desktop client release.
- Dedicated server Linux release.
- Dedicated server local debug.

Do not export secrets inside client builds.

## Dedicated server export

Dedicated server export runs headless. It must not load client-only UI, audio, VFX, or mobile plugins. Keep server scene dependencies clean.

## Environment config

Environment config includes:

- backend URL
- matchmaking region
- build channel
- telemetry endpoint
- feature flags
- content version
- protocol version
- log level

Never hardcode production secrets in project files.

## Compatibility gates

The client must send:

- build version
- protocol version
- content manifest hash

The server rejects incompatible clients with a clear reason.

## CI targets

CI must run:

- content validation
- GDScript syntax/static checks where available
- unit tests
- headless simulation tests
- network message schema validation
- bot soak smoke test
- export dry run for server

Mobile export can run in release CI if certificates and credentials are configured.
