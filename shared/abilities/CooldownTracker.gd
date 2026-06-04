class_name CooldownTracker
extends RefCounted

static func get_remaining(entity: Dictionary, slot: String) -> float:
	return float(entity.get("cooldowns", {}).get(slot, 0.0))

static func set_cooldown(state: SimulationState, entity_id: int, slot: String, seconds: float) -> void:
	var entity := state.get_entity(entity_id)
	var cooldowns: Dictionary = entity.get("cooldowns", {}).duplicate(true)
	cooldowns[slot] = max(0.0, seconds)
	state.patch_entity(entity_id, {"cooldowns": cooldowns})

static func tick_cooldowns(state: SimulationState, entity: Dictionary, delta: float) -> void:
	var cooldowns: Dictionary = entity.get("cooldowns", {}).duplicate(true)
	var changed := false
	for slot in cooldowns.keys():
		var current_value: float = float(cooldowns[slot])
		var next_value: float = max(0.0, current_value - delta)
		if next_value != current_value:
			cooldowns[slot] = next_value
			changed = true
	if changed:
		state.patch_entity(int(entity.get("entity_id", 0)), {"cooldowns": cooldowns})
