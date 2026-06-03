class_name StatusEffectRuntime
extends RefCounted

func tick_statuses(state: SimulationState) -> void:
	for entity_id in state.query_entities({"kind": "hero"}):
		var entity := state.get_entity(entity_id)
		var tags: Array = entity.get("status_tags", []).duplicate(true)
		if bool(entity.get("alive", true)) and state.server_tick >= int(entity.get("invulnerable_until_tick", 0)):
			tags.erase("invulnerable")
			if not tags.has("alive"):
				tags.append("alive")
			state.patch_entity(entity_id, {"status_tags": tags})
