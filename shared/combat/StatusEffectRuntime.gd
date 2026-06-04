class_name StatusEffectRuntime
extends RefCounted

func tick_entity(entity: Dictionary, state: SimulationState) -> void:
	var patch := {}
	if int(entity.get("invuln_ticks", 0)) > 0:
		patch["invuln_ticks"] = int(entity.get("invuln_ticks", 0)) - 1
	if int(entity.get("shield_decay_ticks", 0)) > 0:
		var remaining := int(entity.get("shield_decay_ticks", 0)) - 1
		patch["shield_decay_ticks"] = remaining
		if remaining <= 0:
			patch["shield"] = 0
	if not patch.is_empty():
		state.patch_entity(int(entity.get("entity_id", 0)), patch)
