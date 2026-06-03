class_name ReconciliationService
extends RefCounted

func build_correction(player_id: String, entity: Dictionary, last_input: int, server_tick: int) -> Dictionary:
	var position: Vector2 = entity.get("position", Vector2.ZERO)
	return {
		"player_id": player_id,
		"server_tick": server_tick,
		"last_processed_input": last_input,
		"entity_id": int(entity.get("entity_id", 0)),
		"authoritative_state": {
			"position": {"x": position.x, "y": position.y},
			"health": {"current": int(entity.get("health_current", 0)), "max": int(entity.get("health_max", 1))},
		},
		"reason": "authoritative_snapshot",
	}
