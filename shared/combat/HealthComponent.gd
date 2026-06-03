class_name HealthComponent
extends RefCounted

static func apply_heal(entity: Dictionary, amount: int) -> Dictionary:
	var max_health: int = int(entity.get("health_max", 1))
	var current: int = int(entity.get("health_current", max_health))
	return {"health_current": min(max_health, current + max(amount, 0))}

static func health_ratio(entity: Dictionary) -> float:
	var max_health: int = max(int(entity.get("health_max", 1)), 1)
	return float(entity.get("health_current", 0)) / float(max_health)
