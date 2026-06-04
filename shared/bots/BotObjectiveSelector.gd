class_name BotObjectiveSelector
extends RefCounted

static func select_objective(perception: BotPerception, profile: BotDifficultyProfile) -> String:
	if perception.self_health_ratio <= profile.retreat_health_ratio:
		return "retreat_to_safe_zone"
	if not perception.visible_enemies.is_empty():
		return "attack_enemy"
	if profile.objective_priority > 0.45:
		return "return_to_lane_or_center"
	return "kite_enemy"
