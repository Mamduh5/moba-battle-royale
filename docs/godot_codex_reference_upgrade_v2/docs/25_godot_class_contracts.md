# 25 - Godot Class Contracts

These are the concrete classes Codex must create or preserve. If the repository already has equivalent classes, create an adapter or mapping document instead of duplicating systems.

## Autoload classes

### `GameConfig`
Path: `res://autoload/GameConfig.gd`

Responsibilities:

- Load runtime environment: `local`, `dev`, `staging`, `prod`.
- Expose server address, Nakama address, protocol version, tick rate, content path.
- Never store secrets in exported client builds.

Public API:

```gdscript
func get_env() -> String
func get_protocol_version() -> String
func get_tick_rate() -> int
func get_nakama_scheme() -> String
func get_nakama_host() -> String
func get_nakama_port() -> int
func get_match_server_host() -> String
func get_match_server_port() -> int
```

### `ContentDB`
Path: `res://autoload/ContentDB.gd`

Responsibilities:

- Load content JSON.
- Validate content before gameplay starts.
- Provide read-only definitions by ID.

Public API:

```gdscript
func load_all() -> bool
func validate_all() -> Array[String]
func get_hero(hero_id: String) -> HeroDef
func get_ability(ability_id: String) -> AbilityDef
func get_mode(mode_id: String) -> ModeDef
func get_map(map_id: String) -> MapDef
func get_bot_profile(profile_id: String) -> BotProfileDef
```

### `DebugBus`
Path: `res://autoload/DebugBus.gd`

Responsibilities:

- Central structured logs.
- Trace IDs for match, player, entity, and tick.
- Debug overlays and file traces.

Public API:

```gdscript
func info(category: String, event: String, fields: Dictionary = {}) -> void
func warn(category: String, event: String, fields: Dictionary = {}) -> void
func error(category: String, event: String, fields: Dictionary = {}) -> void
func set_trace_enabled(enabled: bool) -> void
func write_trace_line(fields: Dictionary) -> void
```

### `Protocol`
Path: `res://autoload/Protocol.gd`

Responsibilities:

- Central message type constants.
- Protocol version.
- Encode/decode through `NetworkCodec`.

Public API:

```gdscript
func get_version() -> String
func encode(message_type: String, payload: Dictionary, metadata: Dictionary = {}) -> PackedByteArray
func decode(bytes: PackedByteArray) -> NetworkEnvelope
```

## Shared network classes

### `NetworkEnvelope`
Path: `res://shared/net/NetworkEnvelope.gd`

Fields:

```gdscript
var protocol_version: String
var message_type: String
var match_id: String
var player_id: String
var sequence: int
var client_tick: int
var server_tick: int
var sent_at_ms: int
var payload: Dictionary
```

Public API:

```gdscript
func to_dict() -> Dictionary
static func from_dict(data: Dictionary) -> NetworkEnvelope
func validate_basic() -> Array[String]
```

### `InputFrame`
Path: `res://shared/net/InputFrame.gd`

Fields:

```gdscript
var player_id: String
var input_sequence: int
var client_tick: int
var move_x: float
var move_y: float
var aim_x: float
var aim_y: float
var buttons: Dictionary
var cast_requests: Array[Dictionary]
```

Public API:

```gdscript
func normalized() -> InputFrame
func is_valid() -> bool
func to_dict() -> Dictionary
static func from_dict(data: Dictionary) -> InputFrame
```

`move_x`, `move_y`, `aim_x`, and `aim_y` must be clamped to `[-1.0, 1.0]`. Server validation must reject or clamp invalid values.

### `SnapshotFrame`
Path: `res://shared/net/SnapshotFrame.gd`

Fields:

```gdscript
var match_id: String
var server_tick: int
var snapshot_id: int
var last_processed_input_by_player: Dictionary
var entities: Array[Dictionary]
var events: Array[Dictionary]
var scoreboard: Dictionary
```

Public API:

```gdscript
func to_dict() -> Dictionary
static func from_dict(data: Dictionary) -> SnapshotFrame
func get_entity(entity_id: int) -> Dictionary
```

## Simulation classes

### `SimulationWorld`
Path: `res://shared/simulation/SimulationWorld.gd`

Responsibilities:

- Own simulation state.
- Advance exactly one authoritative tick at a time.
- Apply input frames.
- Run movement, abilities, combat, objectives, deaths, respawns.
- Emit simulation events.

Public API:

```gdscript
func configure(config: SimulationConfig, content_db: Object) -> void
func reset(match_seed: int, mode_id: String, map_id: String) -> void
func add_player(player_id: String, hero_id: String, team_id: int, spawn_id: String) -> int
func remove_player(player_id: String) -> void
func queue_input(input: InputFrame) -> void
func step_tick() -> Array[Dictionary]
func build_snapshot() -> SnapshotFrame
func get_state() -> SimulationState
func get_tick() -> int
```

### `SimulationState`
Path: `res://shared/simulation/SimulationState.gd`

Responsibilities:

- Store entities, teams, cooldowns, health, statuses, objectives, score, timers.
- Provide read/write methods used by systems.

Public API:

```gdscript
func create_entity(archetype: String, owner_player_id: String = "") -> int
func remove_entity(entity_id: int) -> void
func has_entity(entity_id: int) -> bool
func get_entity(entity_id: int) -> Dictionary
func patch_entity(entity_id: int, patch: Dictionary) -> void
func query_entities(filter: Dictionary = {}) -> Array[int]
func push_event(event: Dictionary) -> void
func drain_events() -> Array[Dictionary]
```

### `DamageResolver`
Path: `res://shared/combat/DamageResolver.gd`

Responsibilities:

- Validate damage request.
- Apply shields, armor, modifiers, invulnerability, team rules.
- Emit damage events.
- Trigger death resolver when health reaches zero.

Public API:

```gdscript
func resolve_damage(request: DamageRequest, state: SimulationState) -> DamageResult
func can_damage(source_entity_id: int, target_entity_id: int, state: SimulationState) -> bool
```

### `AbilityRuntime`
Path: `res://shared/abilities/AbilityRuntime.gd`

Responsibilities:

- Validate cast request.
- Check cooldowns, mana/energy, range, target rules.
- Spawn projectile/area effects or apply instant effects.
- Start cooldown only after authoritative cast acceptance.

Public API:

```gdscript
func can_cast(ctx: AbilityContext) -> Array[String]
func cast(ctx: AbilityContext) -> Array[Dictionary]
func tick_active_effects(state: SimulationState) -> Array[Dictionary]
```

## Server classes

### `MatchServerApp`
Path: `res://server/main/MatchServerApp.gd`

Responsibilities:

- Start headless server app.
- Parse CLI settings.
- Load content.
- Start match server transport.
- Create and supervise match rooms.

Public API:

```gdscript
func boot(args: Dictionary) -> int
func shutdown(reason: String) -> void
```

### `MatchServer`
Path: `res://server/network/MatchServer.gd`

Responsibilities:

- Accept socket/websocket connections.
- Authenticate match tokens.
- Route messages to MatchRoom.
- Send snapshots and events.

Public API:

```gdscript
func start(host: String, port: int) -> bool
func stop() -> void
func poll_network() -> void
func send_to_player(player_id: String, message_type: String, payload: Dictionary) -> void
func broadcast(match_id: String, message_type: String, payload: Dictionary) -> void
```

### `MatchRoom`
Path: `res://server/match/MatchRoom.gd`

Responsibilities:

- Own one running match.
- Own SimulationWorld.
- Track connected sessions.
- Process inputs and bots each tick.
- Build result and report to Nakama.

Public API:

```gdscript
func configure(match_config: Dictionary, content_db: Object) -> void
func add_session(session: ClientSession) -> void
func remove_session(player_id: String, reason: String) -> void
func receive_input(player_id: String, input: InputFrame) -> void
func tick(delta: float) -> void
func is_finished() -> bool
func build_result() -> Dictionary
```

## Client classes

### `MatchClient`
Path: `res://client/network/MatchClient.gd`

Responsibilities:

- Connect to match server.
- Send hello/join/input frames.
- Receive snapshots, corrections, events.
- Maintain prediction buffer and interpolation state.

Public API:

```gdscript
func connect_to_match(host: String, port: int, token: String) -> bool
func disconnect_from_match(reason: String) -> void
func send_input(input: InputFrame) -> void
func poll_network() -> void
func get_connection_state() -> String
```

### `InputSampler`
Path: `res://client/input/InputSampler.gd`

Responsibilities:

- Convert device input to InputFrame.
- Support mobile joystick/buttons and keyboard/mouse.
- Never apply damage or cooldowns.

Public API:

```gdscript
func sample(player_id: String, client_tick: int, sequence: int) -> InputFrame
func set_input_adapter(adapter: Object) -> void
```

### `EntityViewBinder`
Path: `res://client/presentation/EntityViewBinder.gd`

Responsibilities:

- Bind snapshot entity data to scene nodes.
- Spawn/despawn presentation actors.
- Smooth position and rotation.
- Route VFX/SFX without changing simulation state.

Public API:

```gdscript
func apply_snapshot(snapshot: SnapshotFrame) -> void
func apply_events(events: Array[Dictionary]) -> void
func clear() -> void
```

## Bot classes

### `BotBrain`
Path: `res://shared/bots/BotBrain.gd`

Responsibilities:

- Read BotPerception.
- Select objective, target, movement, and abilities.
- Output InputFrame through BotInputBuilder.

Public API:

```gdscript
func configure(profile: BotDifficultyProfile, hero_id: String) -> void
func build_input_frame(perception: BotPerception, tick: int, sequence: int) -> InputFrame
```

## Done condition

The class contract is satisfied only when all listed classes either exist or are mapped to equivalent existing classes, and each public API is implemented or explicitly marked with a failing test that names the missing behavior.
