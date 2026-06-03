class_name SimulationState
extends RefCounted

var match_id := ""
var mode_id := ""
var map_id := ""
var mode_def: ModeDef = null
var map_def: MapDef = null
var server_tick := 0
var match_status := GameConstants.MATCH_STATE_LOBBY
var match_end_reason := ""
var winning_team_id := GameConstants.TEAM_NONE
var remaining_ticks := 0
var score_by_team: Dictionary = {}
var player_stats: Dictionary = {}
var last_processed_input_by_player: Dictionary = {}
var spawn_by_player: Dictionary = {}
var participant_order: Array[String] = []
var match_finished_event_emitted := false

var _registry := EntityRegistry.new()
var _events: Array[Dictionary] = []

func configure_match(new_match_id: String, config: SimulationConfig) -> void:
	match_id = new_match_id
	mode_id = config.mode_id
	map_id = config.map_id
	mode_def = config.mode_def
	map_def = config.map_def
	server_tick = 0
	match_status = GameConstants.MATCH_STATE_RUNNING
	match_end_reason = ""
	winning_team_id = GameConstants.TEAM_NONE
	remaining_ticks = config.match_duration_ticks
	score_by_team.clear()
	player_stats.clear()
	last_processed_input_by_player.clear()
	spawn_by_player.clear()
	participant_order.clear()
	match_finished_event_emitted = false
	_registry.reset()
	if config.team_based:
		score_by_team[str(GameConstants.TEAM_A)] = 0
		score_by_team[str(GameConstants.TEAM_B)] = 0

func create_entity(archetype: String, owner_player_id: String = "") -> int:
	var entity_id := _registry.create({
		"archetype": archetype,
		"kind": archetype,
		"owner_player_id": owner_player_id,
		"team_id": GameConstants.TEAM_NONE,
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"facing": Vector2.RIGHT,
		"radius": 12.0,
		"alive": true,
		"status_tags": ["alive"],
		"health_current": 1,
		"health_max": 1,
		"shield": 0.0,
		"cooldowns": {},
		"respawn_tick": 0,
		"invulnerable_until_tick": 0,
	})
	return entity_id

func remove_entity(entity_id: int) -> void:
	_registry.remove(entity_id)

func has_entity(entity_id: int) -> bool:
	return _registry.has(entity_id)

func get_entity(entity_id: int) -> Dictionary:
	return _registry.get_entity(entity_id)

func patch_entity(entity_id: int, patch: Dictionary) -> void:
	_registry.patch(entity_id, patch)

func query_entities(filter: Dictionary = {}) -> Array[int]:
	var result: Array[int] = []
	for entity_id in _registry.all().keys():
		var entity: Dictionary = _registry.get_entity(int(entity_id))
		var matches := true
		for key in filter.keys():
			if not entity.has(key) or entity[key] != filter[key]:
				matches = false
				break
		if matches:
			result.append(int(entity_id))
	return result

func push_event(event: Dictionary) -> void:
	var enriched := event.duplicate(true)
	if not enriched.has("server_tick"):
		enriched["server_tick"] = server_tick
	if not enriched.has("match_id"):
		enriched["match_id"] = match_id
	if not enriched.has("event_id"):
		enriched["event_id"] = "evt_%s_%06d" % [str(server_tick), _events.size() + 1]
	_events.append(enriched)

func drain_events() -> Array[Dictionary]:
	var drained := _events.duplicate(true)
	_events.clear()
	return drained

func get_entity_for_player(player_id: String) -> int:
	for entity_id in query_entities({"owner_player_id": player_id, "kind": "hero"}):
		return entity_id
	return 0

func ensure_player_stats(player_id: String, hero_id: String, team_id: int, is_bot: bool) -> void:
	if player_stats.has(player_id):
		return
	player_stats[player_id] = {
		"player_id": player_id,
		"hero_id": hero_id,
		"team_id": team_id,
		"is_bot": is_bot,
		"kills": 0,
		"deaths": 0,
		"assists": 0,
		"damage_dealt": 0,
		"score": 0,
		"entity_id": 0,
	}
	participant_order.append(player_id)

func set_player_entity(player_id: String, entity_id: int) -> void:
	if not player_stats.has(player_id):
		return
	var stats: Dictionary = player_stats[player_id]
	stats["entity_id"] = entity_id
	player_stats[player_id] = stats

func record_damage(source_player_id: String, amount: int) -> void:
	if not player_stats.has(source_player_id):
		return
	var stats: Dictionary = player_stats[source_player_id]
	stats["damage_dealt"] = int(stats.get("damage_dealt", 0)) + max(amount, 0)
	player_stats[source_player_id] = stats

func record_kill(source_player_id: String, target_player_id: String, kill_score: int) -> void:
	if player_stats.has(target_player_id):
		var target_stats: Dictionary = player_stats[target_player_id]
		target_stats["deaths"] = int(target_stats.get("deaths", 0)) + 1
		player_stats[target_player_id] = target_stats
	if source_player_id != "" and source_player_id != target_player_id and player_stats.has(source_player_id):
		var source_stats: Dictionary = player_stats[source_player_id]
		source_stats["kills"] = int(source_stats.get("kills", 0)) + 1
		source_stats["score"] = int(source_stats.get("score", 0)) + kill_score
		player_stats[source_player_id] = source_stats
		if mode_def != null and mode_def.team_based:
			var team_key := str(int(source_stats.get("team_id", 0)))
			score_by_team[team_key] = int(score_by_team.get(team_key, 0)) + kill_score

func build_scoreboard() -> Dictionary:
	var scoreboard := {
		"mode_id": mode_id,
		"server_tick": server_tick,
		"remaining_ticks": remaining_ticks,
		"remaining_sec": int(ceil(float(max(remaining_ticks, 0)) / 30.0)),
		"player_results": player_stats.duplicate(true),
		"rankings": build_rankings(),
	}
	if mode_def != null and mode_def.team_based:
		scoreboard["teams"] = {
			str(GameConstants.TEAM_A): {"score": int(score_by_team.get(str(GameConstants.TEAM_A), 0))},
			str(GameConstants.TEAM_B): {"score": int(score_by_team.get(str(GameConstants.TEAM_B), 0))},
		}
		scoreboard["winning_team_id"] = winning_team_id
	return scoreboard

func build_rankings() -> Array[Dictionary]:
	var rankings: Array[Dictionary] = []
	for player_id in player_stats.keys():
		var stats: Dictionary = player_stats[player_id]
		rankings.append(stats.duplicate(true))
	rankings.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("score", 0)) != int(b.get("score", 0)):
			return int(a.get("score", 0)) > int(b.get("score", 0))
		if int(a.get("deaths", 0)) != int(b.get("deaths", 0)):
			return int(a.get("deaths", 0)) < int(b.get("deaths", 0))
		if int(a.get("damage_dealt", 0)) != int(b.get("damage_dealt", 0)):
			return int(a.get("damage_dealt", 0)) > int(b.get("damage_dealt", 0))
		return str(a.get("player_id", "")) < str(b.get("player_id", ""))
	)
	var rank := 1
	for entry in rankings:
		entry["rank"] = rank
		rank += 1
	return rankings

func finish_match(reason: String, winning_team: int = GameConstants.TEAM_NONE) -> void:
	if match_status == GameConstants.MATCH_STATE_FINISHED:
		return
	match_status = GameConstants.MATCH_STATE_FINISHED
	match_end_reason = reason
	winning_team_id = winning_team
	if not match_finished_event_emitted:
		match_finished_event_emitted = true
		push_event({
			"type": "match_finished",
			"reason": reason,
			"winning_team_id": winning_team_id,
			"scoreboard": build_scoreboard(),
		})

func snapshot_entities() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entity_id in _registry.all().keys():
		var entity: Dictionary = _registry.get_entity(int(entity_id))
		out.append(_entity_to_snapshot(entity))
	return out

func _entity_to_snapshot(entity: Dictionary) -> Dictionary:
	var position: Vector2 = entity.get("position", Vector2.ZERO)
	var velocity: Vector2 = entity.get("velocity", Vector2.ZERO)
	var facing: Vector2 = entity.get("facing", Vector2.RIGHT)
	return {
		"entity_id": int(entity.get("entity_id", 0)),
		"kind": str(entity.get("kind", "")),
		"owner_player_id": str(entity.get("owner_player_id", "")),
		"team_id": int(entity.get("team_id", 0)),
		"hero_id": str(entity.get("hero_id", "")),
		"position": {"x": position.x, "y": position.y},
		"velocity": {"x": velocity.x, "y": velocity.y},
		"facing": {"x": facing.x, "y": facing.y},
		"radius": float(entity.get("radius", 12.0)),
		"alive": bool(entity.get("alive", true)),
		"health": {"current": int(entity.get("health_current", 0)), "max": int(entity.get("health_max", 1)), "shield": int(entity.get("shield", 0))},
		"status_tags": entity.get("status_tags", []).duplicate(true),
		"cooldowns": entity.get("cooldowns", {}).duplicate(true),
		"visual": entity.get("visual", {}).duplicate(true),
		"ability_slots": entity.get("ability_slots", {}).duplicate(true),
	}
