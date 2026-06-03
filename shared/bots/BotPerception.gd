class_name BotPerception
extends RefCounted

var self_entity_id := 0
var self_team_id := 0
var self_entity: Dictionary = {}
var visible_enemies: Array[Dictionary] = []
var nearby_allies: Array[Dictionary] = []
var objectives: Array[Dictionary] = []
var incoming_threats: Array[Dictionary] = []
var current_tick := 0
var map_hints: Dictionary = {}

static func from_state(state: SimulationState, player_id: String) -> BotPerception:
	var perception := BotPerception.new()
	perception.current_tick = state.server_tick
	perception.self_entity_id = state.get_entity_for_player(player_id)
	if perception.self_entity_id == 0:
		return perception
	perception.self_entity = state.get_entity(perception.self_entity_id)
	perception.self_team_id = int(perception.self_entity.get("team_id", 0))
	var self_pos: Vector2 = perception.self_entity.get("position", Vector2.ZERO)
	var damage_resolver := DamageResolver.new()
	for entity_id in state.query_entities({"kind": "hero"}):
		if entity_id == perception.self_entity_id:
			continue
		var entity := state.get_entity(entity_id)
		var entry := {
			"entity_id": entity_id,
			"player_id": str(entity.get("owner_player_id", "")),
			"team_id": int(entity.get("team_id", 0)),
			"position": entity.get("position", Vector2.ZERO),
			"distance": self_pos.distance_to(entity.get("position", Vector2.ZERO)),
			"health_ratio": HealthComponent.health_ratio(entity),
			"alive": bool(entity.get("alive", true)),
		}
		if damage_resolver.can_damage(perception.self_entity_id, entity_id, state):
			perception.visible_enemies.append(entry)
		elif int(entity.get("team_id", 0)) == perception.self_team_id:
			perception.nearby_allies.append(entry)
	perception.visible_enemies.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("distance", 0.0)) < float(b.get("distance", 0.0))
	)
	if state.map_def != null:
		perception.objectives.clear()
		for objective in state.map_def.objective_points:
			perception.objectives.append(objective.duplicate(true))
		perception.map_hints = {
			"bounds": state.map_def.bounds.duplicate(true),
			"mode_id": state.mode_id,
		}
	return perception
