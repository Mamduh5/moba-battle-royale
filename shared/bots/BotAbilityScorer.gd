class_name BotAbilityScorer
extends RefCounted

static func choose_slot(perception: BotPerception, profile: BotDifficultyProfile, target_distance: float) -> String:
	if perception.visible_enemies.is_empty():
		return ""
	if target_distance < 170.0 and profile.skill_usage > 0.65:
		return GameConstants.SLOT_ABILITY_1
	if target_distance < 250.0 and profile.aggression > 0.75:
		return GameConstants.SLOT_ULTIMATE
	return GameConstants.SLOT_BASIC
