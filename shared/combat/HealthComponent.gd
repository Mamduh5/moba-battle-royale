class_name HealthComponent
extends RefCounted

static func is_alive(entity: Dictionary) -> bool:
	return entity.get("status_tags", []).has(GameConstants.STATUS_ALIVE) and int(entity.get("health", {}).get("current", 0)) > 0

static func health_ratio(entity: Dictionary) -> float:
	var health: Dictionary = entity.get("health", {})
	var max_health: int = max(1, int(health.get("max", 1)))
	return float(health.get("current", 0)) / float(max_health)
