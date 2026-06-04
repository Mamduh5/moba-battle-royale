class_name ServerBotManager
extends RefCounted

var _brains: Dictionary = {}
var _sequences: Dictionary = {}
var _profile: BotDifficultyProfile = null

func configure(profile_def: BotProfileDef) -> void:
	_profile = BotDifficultyProfile.from_profile_def(profile_def)

func register_bot(session: ClientSession) -> void:
	var brain := BotBrain.new()
	brain.configure(_profile, session.selected_hero_id)
	_brains[session.player_id] = brain
	_sequences[session.player_id] = 0

func unregister_bot(player_id: String) -> void:
	_brains.erase(player_id)
	_sequences.erase(player_id)

func build_bot_inputs(world: SimulationWorld) -> Array[InputFrame]:
	var frames: Array[InputFrame] = []
	var state := world.get_state()
	for player_id in _brains.keys():
		var entity := state.get_entity_for_player(str(player_id))
		if entity.is_empty():
			continue
		if not HealthComponent.is_alive(entity):
			continue
		var perception := _build_perception(state, entity, world.get_map())
		_sequences[player_id] = int(_sequences.get(player_id, 0)) + 1
		var frame: InputFrame = _brains[player_id].build_input_frame(perception, world.get_tick(), int(_sequences[player_id]), entity.get("ability_by_slot", {}))
		frames.append(frame)
	return frames

func _build_perception(state: SimulationState, self_entity: Dictionary, map_def: MapDef) -> BotPerception:
	var perception := BotPerception.new()
	perception.self_entity_id = int(self_entity.get("entity_id", 0))
	perception.self_player_id = str(self_entity.get("owner_player_id", ""))
	perception.self_team_id = int(self_entity.get("team_id", 0))
	perception.self_health_ratio = HealthComponent.health_ratio(self_entity)
	var self_pos := Vector2(float(self_entity.get("position", {}).get("x", 0.0)), float(self_entity.get("position", {}).get("y", 0.0)))
	perception.map_hints = {"self_x": self_pos.x, "self_y": self_pos.y}
	perception.objectives = map_def.objectives.duplicate(true)
	for entity in state.all_entities():
		if int(entity.get("entity_id", 0)) == perception.self_entity_id:
			continue
		var pos := Vector2(float(entity.get("position", {}).get("x", 0.0)), float(entity.get("position", {}).get("y", 0.0)))
		var entry := entity.duplicate(true)
		entry["x"] = pos.x
		entry["y"] = pos.y
		entry["distance"] = self_pos.distance_to(pos)
		if TeamService.are_hostile(self_entity, entity, state.rules):
			perception.visible_enemies.append(entry)
		else:
			perception.nearby_allies.append(entry)
	return perception
