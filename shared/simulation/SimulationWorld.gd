class_name SimulationWorld
extends RefCounted

var _state := SimulationState.new()
var _tick := 0
var _snapshot_id := 0
var _input_queue: Dictionary = {}
var _last_processed_input_by_player: Dictionary = {}
var _config: SimulationConfig = null
var _content_db: Object = null
var _mode: ModeDef = null
var _map: MapDef = null
var _ability_runtime := AbilityRuntime.new()
var _status_runtime := StatusEffectRuntime.new()
var _victory_resolver := VictoryResolver.new()

func configure(config: SimulationConfig, content_db: Object) -> void:
	_config = config
	_content_db = content_db

func reset(match_seed: int, mode_id: String, map_id: String) -> void:
	_state.reset(match_seed)
	_tick = 0
	_snapshot_id = 0
	_input_queue.clear()
	_last_processed_input_by_player.clear()
	_mode = _content_db.get_mode(mode_id)
	_map = _content_db.get_map(map_id)
	_state.match_id = GameConstants.DEFAULT_MATCH_ID
	_state.mode_id = mode_id
	_state.map_id = map_id
	_state.rules = {
		"teams_enabled": _mode.teams_enabled,
		"friendly_fire": _mode.friendly_fire,
		"kill_score": int(_mode.score.get("kill", 1)),
		"score_limit": _mode.score_limit,
		"duration_ticks": _config.seconds_to_ticks(float(_mode.duration_sec)),
		"respawn_ticks": _config.seconds_to_ticks(_mode.respawn_delay_sec),
		"invuln_ticks": _config.seconds_to_ticks(_mode.invulnerability_sec),
	}
	_state.scoreboard = {
		"mode_id": mode_id,
		"map_id": map_id,
		"ticks_remaining": _state.rules["duration_ticks"],
		"teams": {"1": {"score": 0, "kills": 0}, "2": {"score": 0, "kills": 0}} if _mode.teams_enabled else {},
		"rankings": [],
		"finished": false,
	}
	_state.push_event({"type": "match_reset", "mode_id": mode_id, "map_id": map_id, "seed": match_seed})

func add_player(player_id: String, hero_id: String, team_id: int, spawn_id: String, display_name: String = "", is_bot: bool = false) -> int:
	var hero: HeroDef = _content_db.get_hero(hero_id)
	var entity_id := _state.create_entity("hero", player_id)
	var spawn_position := _resolve_spawn(team_id, spawn_id, entity_id)
	var cooldowns := {}
	for ability_entry in hero.abilities:
		cooldowns[str(ability_entry.get("slot", ""))] = 0.0
	_state.patch_entity(entity_id, {
		"kind": "hero",
		"hero_id": hero_id,
		"team_id": team_id,
		"display_name": display_name if display_name != "" else player_id,
		"is_bot": is_bot,
		"position": {"x": spawn_position.x, "y": spawn_position.y},
		"spawn_position": {"x": spawn_position.x, "y": spawn_position.y},
		"move_speed": hero.move_speed,
		"primary_color": hero.primary_color,
		"accent_color": hero.accent_color,
		"silhouette": hero.silhouette,
		"health": {"current": hero.max_health, "max": hero.max_health},
		"cooldowns": cooldowns,
		"ability_by_slot": hero.get_ability_map(),
		"invuln_ticks": _state.rules.get("invuln_ticks", 0),
	})
	_last_processed_input_by_player[player_id] = 0
	_state.push_event({"type": "player_spawned", "player_id": player_id, "entity_id": entity_id, "hero_id": hero_id, "team_id": team_id})
	return entity_id

func remove_player(player_id: String) -> void:
	for entity_id in _state.query_entities({"owner_player_id": player_id}):
		_state.remove_entity(entity_id)

func queue_input(input: InputFrame) -> void:
	if not input.is_valid():
		return
	var normalized := input.normalized()
	_input_queue[normalized.player_id] = normalized

func step_tick() -> Array[Dictionary]:
	if _state.finished:
		return _state.drain_events()
	_tick += 1
	_state.set_tick(_tick)
	var delta := 1.0 / float(_config.tick_rate)
	_state.scoreboard["ticks_remaining"] = max(0, int(_state.rules.get("duration_ticks", 0)) - _tick)
	_tick_entities(delta)
	_apply_inputs(delta)
	var victory := _victory_resolver.resolve(_state)
	if bool(victory.get("finished", false)):
		_finish_match(victory)
	_state.scoreboard["rankings"] = ScoreService.build_rankings(_state)
	var events := _state.drain_events()
	return events

func build_snapshot() -> SnapshotFrame:
	_snapshot_id += 1
	var snapshot := SnapshotFrame.new()
	snapshot.match_id = _state.match_id
	snapshot.server_tick = _tick
	snapshot.snapshot_id = _snapshot_id
	snapshot.last_processed_input_by_player = _last_processed_input_by_player.duplicate(true)
	snapshot.entities = _state.all_entities()
	snapshot.scoreboard = _state.scoreboard.duplicate(true)
	return snapshot

func get_state() -> SimulationState:
	return _state

func get_tick() -> int:
	return _tick

func get_mode() -> ModeDef:
	return _mode

func get_map() -> MapDef:
	return _map

func _tick_entities(delta: float) -> void:
	for entity in _state.all_entities():
		var entity_id := int(entity.get("entity_id", 0))
		CooldownTracker.tick_cooldowns(_state, entity, delta)
		_status_runtime.tick_entity(entity, _state)
		var latest := _state.get_entity(entity_id)
		if latest.get("status_tags", []).has(GameConstants.STATUS_DEAD):
			var respawn_ticks := int(latest.get("respawn_ticks", 0)) - 1
			if respawn_ticks <= 0:
				_respawn_entity(latest)
			else:
				_state.patch_entity(entity_id, {"respawn_ticks": respawn_ticks})

func _apply_inputs(delta: float) -> void:
	for player_id in _input_queue.keys():
		var input: InputFrame = _input_queue[player_id]
		var entity_id := _state.get_entity_id_for_player(player_id)
		if entity_id == 0:
			continue
		var entity := _state.get_entity(entity_id)
		if not HealthComponent.is_alive(entity):
			continue
		_state.patch_entity(entity_id, MovementMotor.move_entity(entity, input, delta, _map))
		_apply_casts(entity_id, input)
		_last_processed_input_by_player[player_id] = input.input_sequence

func _apply_casts(entity_id: int, input: InputFrame) -> void:
	var entity := _state.get_entity(entity_id)
	var ability_by_slot: Dictionary = entity.get("ability_by_slot", {})
	var requests := input.cast_requests.duplicate(true)
	for slot in [GameConstants.SLOT_BASIC, GameConstants.SLOT_ABILITY_1, GameConstants.SLOT_ULTIMATE]:
		if bool(input.buttons.get(slot, false)) and ability_by_slot.has(slot):
			requests.append({
				"slot": slot,
				"ability_id": str(ability_by_slot[slot]),
				"target_entity_id": 0,
				"target_position": entity.get("position", {}),
				"aim": {"x": input.aim_x, "y": input.aim_y},
			})
	for request in requests:
		var slot := str(request.get("slot", ""))
		var ability_id := str(request.get("ability_id", ability_by_slot.get(slot, "")))
		if ability_id == "":
			continue
		var ability: AbilityDef = _content_db.get_ability(ability_id)
		if ability == null:
			continue
		var ctx := AbilityContext.make(_state, entity_id, ability, request, _map, _config.tick_rate)
		_ability_runtime.cast(ctx)

func _respawn_entity(entity: Dictionary) -> void:
	var entity_id := int(entity.get("entity_id", 0))
	var health: Dictionary = entity.get("health", {})
	health["current"] = int(health.get("max", 1))
	var spawn_position := _resolve_spawn(int(entity.get("team_id", 0)), "", entity_id)
	_state.patch_entity(entity_id, {
		"status_tags": [GameConstants.STATUS_ALIVE],
		"respawn_ticks": 0,
		"invuln_ticks": _state.rules.get("invuln_ticks", 0),
		"position": {"x": spawn_position.x, "y": spawn_position.y},
		"health": health,
	})
	_state.push_event({"type": "entity_respawned", "entity_id": entity_id, "player_id": str(entity.get("owner_player_id", ""))})

func _resolve_spawn(team_id: int, spawn_id: String, entity_id: int) -> Vector2:
	var spawns: Array = []
	if _mode.teams_enabled:
		spawns = _map.spawns.get("team_%d" % team_id, [])
	else:
		spawns = _map.spawns.get("ffa", [])
	if spawns.is_empty():
		var bounds := _map.get_bounds_rect()
		return bounds.position + bounds.size * 0.5
	var index: int = max(0, entity_id) % spawns.size()
	if spawn_id != "":
		for i in range(spawns.size()):
			if str(spawns[i].get("id", "")) == spawn_id:
				index = i
				break
	var spawn: Dictionary = spawns[index]
	return Vector2(float(spawn.get("x", 0.0)), float(spawn.get("y", 0.0)))

func _finish_match(victory: Dictionary) -> void:
	if _state.finished:
		return
	_state.finished = true
	_state.finish_reason = str(victory.get("reason", "unknown"))
	_state.winning_team_id = int(victory.get("winning_team_id", 0))
	_state.scoreboard["finished"] = true
	_state.scoreboard["finish_reason"] = _state.finish_reason
	_state.scoreboard["winning_team_id"] = _state.winning_team_id
	_state.scoreboard["winner_player_id"] = str(victory.get("winner_player_id", ""))
	_state.push_event({
		"type": "match_finished",
		"match_id": _state.match_id,
		"reason": _state.finish_reason,
		"winning_team_id": _state.winning_team_id,
		"winner_player_id": str(victory.get("winner_player_id", "")),
	})
