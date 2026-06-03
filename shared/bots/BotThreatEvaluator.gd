class_name BotThreatEvaluator
extends RefCounted

func nearest_enemy(perception: BotPerception) -> Dictionary:
	if perception.visible_enemies.is_empty():
		return {}
	return perception.visible_enemies[0]

func danger_score(perception: BotPerception) -> float:
	var nearest := nearest_enemy(perception)
	if nearest.is_empty():
		return 0.0
	var distance: float = max(float(nearest.get("distance", 9999.0)), 1.0)
	return clampf(520.0 / distance, 0.0, 1.0)
