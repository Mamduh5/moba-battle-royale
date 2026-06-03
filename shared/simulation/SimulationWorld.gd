class_name SimulationWorld
extends RefCounted

var _state := SimulationState.new()
var _tick := 0
var _snapshot_id := 0
var _input_queue: Dictionary = {}
var _config: SimulationConfig = null
var _content_db: Object = null
var _ability_runtime := AbilityRuntime.new()
var _victory_resolver := VictoryResolver.new()
var _status_runtime := StatusEffectRuntime.new()
var _rng := DeterministicRng.new()

func configure(config: SimulationConfig, content_db: Object) -> void:
	_config = config
	_content_db = content_db

func reset(match_seed: int, mode_id: String, map_id: String) -> void:
	assert(_content_db != null)
	var mode: ModeDef = _content_db.get_mode(mode_id)
	var map: MapDef = _content_db.get_map(map_id)
	_config = SimulationConfig.from_defs(mode, map, 30)
	_state = SimulationState.new()
	_tick = 0
	_snapshot_id = 0
	_input_queue.clear()
	_rng.seed(match_seed)
	_state.configure_match("match_%d" % match_seed, _config)
	_state.push_event({"type": "match_reset", "mode_id": mode_id, "map_id": map_id, "seed": match_seed})

func add_player(player_id: String, hero_id: String, team_id: int, spawn_id: String) -> int:
	var hero: HeroDef = _content_db.get_hero(hero_id)
	assert(hero != null)
	var entity_id := _state.create_entity("hero", player_id)
	var spawn_pos := _state.map_def.get_spawn_position(spawn_id) if _state.map_def != null else Vector2.ZERO
	var cooldowns := {
		GameConstants.SLOT_BASIC: 0.0,
		GameConstants.SLOT_ABILITY_1: 0.0,
		GameConstants.SLOT_ABILITY_2: 0.0,
		GameConstants.SLOT_ULTIMATE: 0.0,
	}
	var ability_data_by_slot: Dictionary = {}
	for slot in hero.ability_slots.keys():
		var ability: AbilityDef = _content_db.get_ability(str(hero.ability_slots[slot]))
		if ability != null:
			ability_data_by_slot[slot] = ability.raw.duplicate(true)
	_state.ensure_player_stats(player_id, hero_id, team_id, player_id.begins_with(GameConstants.BOT_PREFIX))
	_state.set_player_entity(player_id, entity_id)
	_state.spawn_by_player[player_id] = spawn_id
	_state.patch_entity(entity_id, {
		"kind": "hero",
		"hero_id": hero_id,
		"team_id": team_id,
		"spawn_id": spawn_id,
		"position": spawn_pos,
		"velocity": Vector2.ZERO,
		"facing": Vector2.RIGHT if team_id != GameConstants.TEAM_B else Vector2.LEFT,
		"radius": hero.get_radius(),
		"health_current": hero.get_max_health(),
		"health_max": hero.get_max_health(),
		"armor": hero.get_armor(),
		"shield": 0.0,
		"cooldowns": cooldowns,
		"ability_slots": hero.ability_slots.duplicate(true),
		"ability_data_by_slot": ability_data_by_slot,
		"visual": hero.visual.duplicate(true),
		"alive": true,
		"status_tags": ["alive", "invulnerable"],
		"invulnerable_until_tick": _tick + (_config.invulnerability_ticks if _config != null else 30),
	})
	_state.push_event({"type": "player_spawned", "player_id": player_id, "entity_id": entity_id, "tick": _tick, "team_id": team_id})
	return entity_id

func remove_player(player_id: String) -> void:
	for entity_id in _state.query_entities({"owner_player_id": player_id}):
		_state.remove_entity(entity_id)

func queue_input(input: InputFrame) -> void:
	if not input.is_valid():
		_state.push_event({"type": "invalid_input_rejected", "player_id": input.player_id, "input_sequence": input.input_sequence})
		return
	_input_queue[input.player_id] = input.normalized()

func step_tick() -> Array[Dictionary]:
	if _config == null or _state.match_status == GameConstants.MATCH_STATE_FINISHED:
		return _state.drain_events()
	_tick += 1
	_state.server_tick = _tick
	_state.remaining_ticks -= 1
	_process_respawns()
	_tick_cooldowns()
	_process_inputs()
	_ability_runtime.tick_active_effects(_state)
	_status_runtime.tick_statuses(_state)
	_victory_resolver.evaluate(_state)
	var events := _state.drain_events()
	_input_queue.clear()
	return events

func build_snapshot() -> SnapshotFrame:
	_snapshot_id += 1
	var snapshot := SnapshotFrame.new()
	snapshot.match_id = _state.match_id
	snapshot.server_tick = _tick
	snapshot.snapshot_id = _snapshot_id
	snapshot.last_processed_input_by_player = _state.last_processed_input_by_player.duplicate(true)
	snapshot.entities = _state.snapshot_entities()
	snapshot.events = []
	snapshot.scoreboard = _state.build_scoreboard()
	return snapshot

func get_state() -> SimulationState:
	return _state

func get_tick() -> int:
	return _tick

func _tick_cooldowns() -> void:
	for entity_id in _state.query_entities({"kind": "hero"}):
		var entity := _state.get_entity(entity_id)
		_state.patch_entity(entity_id, CooldownTracker.tick_entity(entity, _config.fixed_delta))

func _process_inputs() -> void:
	for player_id in _input_queue.keys():
		var input: InputFrame = _input_queue[player_id]
		var entity_id := _state.get_entity_for_player(player_id)
		if entity_id == 0:
			continue
		var entity := _state.get_entity(entity_id)
		_state.last_processed_input_by_player[player_id] = input.input_sequence
		if bool(entity.get("alive", true)):
			var hero: HeroDef = _content_db.get_hero(str(entity.get("hero_id", "")))
			var speed := hero.get_move_speed() if hero != null else 170.0
			_state.patch_entity(entity_id, MovementMotor.apply_input(entity, input, speed, _config.fixed_delta, _config.map_def))
			_process_casts(entity_id, input)

func _process_casts(entity_id: int, input: InputFrame) -> void:
	var entity := _state.get_entity(entity_id)
	var slots: Dictionary = entity.get("ability_slots", {})
	var requests: Array[Dictionary] = input.cast_requests.duplicate(true)
	if requests.is_empty():
		for slot in [GameConstants.SLOT_BASIC, GameConstants.SLOT_ABILITY_1, GameConstants.SLOT_ULTIMATE]:
			if bool(input.buttons.get(slot, false)):
				requests.append({"slot": slot, "ability_id": str(slots.get(slot, ""))})
	for request in requests:
		var slot := str(request.get("slot", ""))
		var ability_id := str(request.get("ability_id", slots.get(slot, "")))
		if ability_id == "":
			continue
		var ctx := AbilityContext.new()
		ctx.caster_entity_id = entity_id
		ctx.slot = slot
		ctx.ability_id = ability_id
		ctx.target_entity_id = int(request.get("target_entity_id", 0))
		var target_pos: Dictionary = request.get("target_position", {})
		ctx.target_position = Vector2(float(target_pos.get("x", 0.0)), float(target_pos.get("y", 0.0)))
		var aim_data: Dictionary = request.get("aim", {"x": input.aim_x, "y": input.aim_y})
		ctx.aim = Vector2(float(aim_data.get("x", input.aim_x)), float(aim_data.get("y", input.aim_y)))
		ctx.state = _state
		ctx.content_db = _content_db
		ctx.config = _config
		_ability_runtime.cast(ctx)

func _process_respawns() -> void:
	for entity_id in _state.query_entities({"kind": "hero"}):
		var entity := _state.get_entity(entity_id)
		if bool(entity.get("alive", true)):
			continue
		var respawn_tick := int(entity.get("respawn_tick", 0))
		if respawn_tick > 0 and _tick >= respawn_tick:
			var player_id := str(entity.get("owner_player_id", ""))
			var spawn_id := str(_state.spawn_by_player.get(player_id, entity.get("spawn_id", "")))
			var spawn_pos := _state.map_def.get_spawn_position(spawn_id) if _state.map_def != null else Vector2.ZERO
			_state.patch_entity(entity_id, {
				"position": spawn_pos,
				"velocity": Vector2.ZERO,
				"health_current": int(entity.get("health_max", 1)),
				"shield": 0.0,
				"alive": true,
				"status_tags": ["alive", "invulnerable"],
				"invulnerable_until_tick": _tick + _config.invulnerability_ticks,
				"respawn_tick": 0,
			})
			_state.push_event({"type": "entity_respawned", "entity_id": entity_id, "player_id": player_id})
