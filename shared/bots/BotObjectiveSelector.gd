class_name BotObjectiveSelector
extends RefCounted

func choose_objective(perception: BotPerception, profile: BotDifficultyProfile) -> String:
	var self_health := HealthComponent.health_ratio(perception.self_entity)
	if self_health <= profile.retreat_health_ratio:
		return "retreat_to_safe_zone"
	if not perception.visible_enemies.is_empty():
		var nearest: Dictionary = perception.visible_enemies[0]
		if float(nearest.get("health_ratio", 1.0)) < 0.35 or profile.aggression >= 0.5:
			return "attack_enemy"
		return "kite_enemy"
	if profile.objective_priority > 0.6 and not perception.objectives.is_empty():
		return "capture_objective"
	return "return_to_lane_or_center"
