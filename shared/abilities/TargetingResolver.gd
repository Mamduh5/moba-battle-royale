class_name TargetingResolver
extends RefCounted

static func find_nearest_enemy(state: SimulationState, source_entity_id: int, max_range: float) -> int:
	var source := state.get_entity(source_entity_id)
	var source_pos: Vector2 = source.get("position", Vector2.ZERO)
	var best_id := 0
	var best_dist_sq := max_range * max_range
	var damage_resolver := DamageResolver.new()
	for entity_id in state.query_entities({"kind": "hero"}):
		if not damage_resolver.can_damage(source_entity_id, entity_id, state):
			continue
		var entity := state.get_entity(entity_id)
		var dist_sq := source_pos.distance_squared_to(entity.get("position", Vector2.ZERO))
		if dist_sq <= best_dist_sq:
			best_dist_sq = dist_sq
			best_id = entity_id
	return best_id

static func find_enemies_in_radius(state: SimulationState, source_entity_id: int, center: Vector2, radius: float) -> Array[int]:
	var result: Array[int] = []
	var damage_resolver := DamageResolver.new()
	for entity_id in state.query_entities({"kind": "hero"}):
		if not damage_resolver.can_damage(source_entity_id, entity_id, state):
			continue
		var entity := state.get_entity(entity_id)
		if center.distance_to(entity.get("position", Vector2.ZERO)) <= radius + float(entity.get("radius", 12.0)):
			result.append(entity_id)
	return result

static func find_enemy_in_arc(state: SimulationState, source_entity_id: int, aim: Vector2, max_range: float, radius: float) -> int:
	var source := state.get_entity(source_entity_id)
	var source_pos: Vector2 = source.get("position", Vector2.ZERO)
	var aim_dir := aim.normalized() if aim.length_squared() > 0.001 else Vector2.RIGHT
	var best_id := 0
	var best_score := 99999999.0
	var damage_resolver := DamageResolver.new()
	for entity_id in state.query_entities({"kind": "hero"}):
		if not damage_resolver.can_damage(source_entity_id, entity_id, state):
			continue
		var entity := state.get_entity(entity_id)
		var to_target: Vector2 = entity.get("position", Vector2.ZERO) - source_pos
		var distance := to_target.length()
		if distance > max_range + float(entity.get("radius", 12.0)):
			continue
		var dot := aim_dir.dot(to_target.normalized()) if distance > 0.001 else 1.0
		if dot < 0.25 and distance > radius:
			continue
		if distance < best_score:
			best_score = distance
			best_id = entity_id
	return best_id
