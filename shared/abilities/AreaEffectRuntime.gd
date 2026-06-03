class_name AreaEffectRuntime
extends RefCounted

func emit_area_event(state: SimulationState, source_entity_id: int, ability: AbilityDef, center: Vector2) -> void:
	state.push_event({
		"type": "area_effect",
		"source_entity_id": source_entity_id,
		"ability_id": ability.id,
		"position": {"x": center.x, "y": center.y},
		"radius": ability.radius,
		"vfx_color": ability.vfx_color,
	})
