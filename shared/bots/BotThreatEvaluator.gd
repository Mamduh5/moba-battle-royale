class_name BotThreatEvaluator
extends RefCounted

static func nearest_enemy(perception: BotPerception) -> Dictionary:
	var best := {}
	var best_distance := 999999.0
	for enemy in perception.visible_enemies:
		var distance := float(enemy.get("distance", 999999.0))
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best
