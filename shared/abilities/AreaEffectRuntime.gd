class_name AreaEffectRuntime
extends RefCounted

func damage_area(ctx: AbilityContext, damage_resolver: DamageResolver) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var caster := ctx.state.get_entity(ctx.caster_entity_id)
	var caster_pos := Vector2(float(caster.get("position", {}).get("x", 0.0)), float(caster.get("position", {}).get("y", 0.0)))
	var center: Vector2 = caster_pos + ctx.aim * min(ctx.ability.range, max(60.0, ctx.ability.range * 0.65))
	for entity in ctx.state.all_entities():
		if not TeamService.are_hostile(caster, entity, ctx.state.rules):
			continue
		var pos := Vector2(float(entity.get("position", {}).get("x", 0.0)), float(entity.get("position", {}).get("y", 0.0)))
		if pos.distance_to(center) <= ctx.ability.radius:
			var request := DamageRequest.make(ctx.caster_entity_id, int(entity.get("entity_id", 0)), ctx.ability.id, ctx.ability.damage)
			results.append(damage_resolver.resolve_damage(request, ctx.state).to_dict())
	ctx.state.push_event({
		"type": "area_effect",
		"source_entity_id": ctx.caster_entity_id,
		"ability_id": ctx.ability.id,
		"position": {"x": center.x, "y": center.y},
		"radius": ctx.ability.radius,
		"color": ctx.ability.vfx_color,
	})
	return results
