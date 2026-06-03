class_name SpawnService
extends RefCounted

func choose_spawn(mode: ModeDef, map_def: MapDef, team_id: int, participant_index: int) -> String:
	if map_def == null:
		return ""
	var candidates: Array = []
	for spawn in map_def.spawn_points:
		var spawn_team := int(spawn.get("team_id", 0))
		if mode != null and mode.team_based:
			if spawn_team == team_id:
				candidates.append(spawn)
		elif spawn_team == GameConstants.TEAM_NONE:
			candidates.append(spawn)
	if candidates.is_empty():
		candidates = map_def.spawn_points
	if candidates.is_empty():
		return ""
	var index := participant_index % candidates.size()
	return str(candidates[index].get("id", ""))

func fallback_spawn_position(map_def: MapDef, participant_index: int) -> Vector2:
	if map_def == null:
		return Vector2.ZERO
	var bounds := map_def.get_bounds_rect()
	var cols := 5
	var rows := 5
	var col := participant_index % cols
	var row := int(participant_index / cols) % rows
	var x := bounds.position.x + bounds.size.x * (float(col) + 0.5) / float(cols)
	var y := bounds.position.y + bounds.size.y * (float(row) + 0.5) / float(rows)
	return Vector2(x, y)
