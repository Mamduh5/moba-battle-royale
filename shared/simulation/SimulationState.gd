class_name SimulationState
extends RefCounted

var match_id := ""
var mode_id := ""
var map_id := ""
var rules: Dictionary = {}
var scoreboard: Dictionary = {}
var finished := false
var finish_reason := ""
var winning_team_id := 0

var _registry := EntityRegistry.new()
var _entities: Dictionary = {}
var _events: Array[Dictionary] = []
var _tick := 0

func reset(seed: int = 1) -> void:
	match_id = ""
	mode_id = ""
	map_id = ""
	rules.clear()
	scoreboard.clear()
	finished = false
	finish_reason = ""
	winning_team_id = 0
	_entities.clear()
	_events.clear()
	_tick = 0
	_registry.reset(seed)

func set_tick(tick: int) -> void:
	_tick = tick

func get_tick() -> int:
	return _tick

func create_entity(archetype: String, owner_player_id: String = "") -> int:
	var entity_id := _registry.next_id()
	_entities[entity_id] = {
		"entity_id": entity_id,
		"archetype": archetype,
		"kind": archetype,
		"owner_player_id": owner_player_id,
		"display_name": owner_player_id,
		"position": {"x": 0.0, "y": 0.0},
		"velocity": {"x": 0.0, "y": 0.0},
		"facing": {"x": 1.0, "y": 0.0},
		"status_tags": [GameConstants.STATUS_ALIVE],
		"cooldowns": {},
		"health": {"current": 1, "max": 1},
		"shield": 0,
		"team_id": GameConstants.TEAM_NONE,
		"is_bot": false,
		"kills": 0,
		"deaths": 0,
		"score": 0,
		"damage_dealt": 0,
		"respawn_ticks": 0,
		"invuln_ticks": 0,
	}
	return entity_id

func remove_entity(entity_id: int) -> void:
	_entities.erase(entity_id)

func has_entity(entity_id: int) -> bool:
	return _entities.has(entity_id)

func get_entity(entity_id: int) -> Dictionary:
	return _entities.get(entity_id, {}).duplicate(true)

func get_entity_ref(entity_id: int) -> Dictionary:
	return _entities.get(entity_id, {})

func patch_entity(entity_id: int, patch: Dictionary) -> void:
	if not _entities.has(entity_id):
		return
	for key in patch.keys():
		_entities[entity_id][key] = patch[key]

func query_entities(filter: Dictionary = {}) -> Array[int]:
	var result: Array[int] = []
	for entity_id in _entities.keys():
		var entity: Dictionary = _entities[entity_id]
		var matches := true
		for key in filter.keys():
			if entity.get(key) != filter[key]:
				matches = false
				break
		if matches:
			result.append(int(entity_id))
	return result

func all_entities() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entity_id in _entities.keys():
		out.append(_entities[entity_id].duplicate(true))
	return out

func get_entity_for_player(player_id: String) -> Dictionary:
	for entity_id in _entities.keys():
		var entity: Dictionary = _entities[entity_id]
		if str(entity.get("owner_player_id", "")) == player_id:
			return entity.duplicate(true)
	return {}

func get_entity_id_for_player(player_id: String) -> int:
	for entity_id in _entities.keys():
		var entity: Dictionary = _entities[entity_id]
		if str(entity.get("owner_player_id", "")) == player_id:
			return int(entity_id)
	return 0

func push_event(event: Dictionary) -> void:
	var copy := event.duplicate(true)
	copy["server_tick"] = int(copy.get("server_tick", _tick))
	copy["event_id"] = str(copy.get("event_id", "evt_%06d_%03d" % [_tick, _events.size()]))
	_events.append(copy)

func drain_events() -> Array[Dictionary]:
	var out := _events.duplicate(true)
	_events.clear()
	return out
