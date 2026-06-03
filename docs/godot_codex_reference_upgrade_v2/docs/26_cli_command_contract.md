# 26 - CLI Command Contract

Godot engine flags are not custom game flags. Custom game commands must be passed after the `--` separator and read with `OS.get_cmdline_user_args()`.

## Required command pattern

Use this pattern for all custom commands:

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd validate-content
```

The script after `-s` is a real Godot script. Arguments after `--` are user arguments. The command router parses them.

## Required command router

Path:

```text
res://server/cli/HeadlessCommandRouter.gd
```

Responsibilities:

- Parse user args.
- Dispatch commands.
- Return process exit code.
- Never silently pass failed validation.

Required commands:

```text
validate-content
run-tests
protocol-check
bot-soak
server-smoke
export-server
```

## Required local commands

### Validate content

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd validate-content
```

Acceptance:

- Loads all JSON in `res://content/`.
- Validates schema-required fields.
- Validates cross references: hero ability IDs, mode map IDs, bot hero IDs.
- Fails on duplicate IDs.
- Fails on missing icons/scenes only when assets are expected by the current milestone.

### Run tests

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd run-tests --suite all
```

Acceptance:

- Runs unit tests first.
- Runs integration tests second.
- Runs protocol tests third.
- Returns non-zero exit code on any failure.

### Protocol check

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd protocol-check
```

Acceptance:

- Encodes and decodes every message example under `docs/codex_reference_upgrade_v2/protocol_examples/` if present.
- Validates protocol version.
- Validates required fields.
- Rejects unknown message types unless explicitly allowed for forward compatibility.

### Bot soak

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd bot-soak --matches 20 --bots 6 --mode mode_team_arena_3v3
```

Acceptance:

- Runs full server simulation with bots only.
- No crashes.
- No invalid ability casts accepted.
- No NaN positions.
- No entity leaks after match cleanup.
- Produces summary: matches, average ticks, kills, deaths, objective captures, errors.

### Server smoke

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd server-smoke --duration-sec 15
```

Acceptance:

- Boots content DB.
- Starts match server transport.
- Creates one local room.
- Adds bot sessions.
- Advances ticks.
- Shuts down cleanly.

### Export server

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd export-server --preset linux_dedicated --out build/server/game_server.x86_64
```

Acceptance:

- Verifies export preset exists.
- Creates output folder.
- Runs export command or prints the exact Godot export command to run if export is intentionally manual in the current environment.

## Required exit codes

```text
0 = success
1 = generic failure
2 = invalid arguments
3 = content validation failure
4 = test failure
5 = protocol failure
6 = server boot failure
7 = bot soak failure
```

## Required implementation sketch

Use this structure:

```gdscript
extends SceneTree

func _init() -> void:
    var args := OS.get_cmdline_user_args()
    var parsed := _parse_args(args)
    var exit_code := _dispatch(parsed)
    quit(exit_code)
```

Do not create commands that only print success. Every command must perform a real check or explicitly fail until implemented.
