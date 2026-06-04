class_name TargetingResolver
extends RefCounted

static func find_target(ctx: AbilityContext) -> int:
	if ctx.state == null or ctx.ability == null:
		return 0
	if ctx.target_entity_id != 0 and ctx.state.has_entity(ctx.target_entity_id):
		var chosen := ctx.state.get_entity(ctx.target_entity_id)
		var caster := ctx.state.get_entity(ctx.caster_entity_id)
		if TeamService.are_hostile(caster, chosen, ctx.state.rules):
			return ctx.target_entity_id
	var caster_entity := ctx.state.get_entity(ctx.caster_entity_id)
	var caster_pos := _dict_to_vec2(caster_entity.get("position", {}))
	var best_id := 0
	var best_distance := 999999.0
	for entity in ctx.state.all_entities():
		if not TeamService.are_hostile(caster_entity, entity, ctx.state.rules):
			continue
		if not HealthComponent.is_alive(entity):
			continue
		var pos := _dict_to_vec2(entity.get("position", {}))
		var distance := caster_pos.distance_to(pos)
		if distance <= ctx.ability.range + ctx.ability.radius and distance < best_distance:
			best_distance = distance
			best_id = int(entity.get("entity_id", 0))
	return best_id

static func _dict_to_vec2(data: Dictionary) -> Vector2:
	return Vector2(float(data.get("x", 0.0)), float(data.get("y", 0.0)))
