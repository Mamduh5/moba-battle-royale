class_name BotAbilityScorer
extends RefCounted

func choose_slot(perception: BotPerception, profile: BotDifficultyProfile, target: Dictionary) -> String:
	if target.is_empty():
		return ""
	var entity := perception.self_entity
	var ability_data: Dictionary = entity.get("ability_data_by_slot", {})
	var distance := float(target.get("distance", 9999.0))
	var slots := [GameConstants.SLOT_ULTIMATE, GameConstants.SLOT_ABILITY_1, GameConstants.SLOT_BASIC]
	for slot in slots:
		if not CooldownTracker.is_ready(entity, slot):
			continue
		var data: Dictionary = ability_data.get(slot, {})
		if data.is_empty():
			continue
		var max_range := float(data.get("range", 0.0))
		var radius := float(data.get("radius", 0.0))
		if distance > max_range + radius + 36.0:
			continue
		if slot == GameConstants.SLOT_ULTIMATE and profile.skill_usage < 0.65 and float(target.get("health_ratio", 1.0)) > 0.45:
			continue
		return slot
	return ""
