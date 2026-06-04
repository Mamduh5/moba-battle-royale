class_name ProjectileRuntime
extends RefCounted

func emit_projectile_event(ctx: AbilityContext, target_entity_id: int) -> void:
	if ctx.state == null:
		return
	ctx.state.push_event({
		"type": "projectile_cast",
		"source_entity_id": ctx.caster_entity_id,
		"target_entity_id": target_entity_id,
		"ability_id": ctx.ability.id,
		"color": ctx.ability.vfx_color,
	})
