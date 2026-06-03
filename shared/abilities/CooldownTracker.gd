class_name CooldownTracker
extends RefCounted

static func tick_entity(entity: Dictionary, delta: float) -> Dictionary:
	var cooldowns: Dictionary = entity.get("cooldowns", {}).duplicate(true)
	for slot in cooldowns.keys():
		cooldowns[slot] = max(float(cooldowns[slot]) - delta, 0.0)
	return {"cooldowns": cooldowns}

static func is_ready(entity: Dictionary, slot: String) -> bool:
	var cooldowns: Dictionary = entity.get("cooldowns", {})
	return float(cooldowns.get(slot, 0.0)) <= 0.0

static func start(entity: Dictionary, slot: String, duration: float) -> Dictionary:
	var cooldowns: Dictionary = entity.get("cooldowns", {}).duplicate(true)
	cooldowns[slot] = max(duration, 0.0)
	return {"cooldowns": cooldowns}
