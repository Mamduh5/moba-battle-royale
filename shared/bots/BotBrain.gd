class_name BotBrain
extends RefCounted

var _profile: BotDifficultyProfile = null
var _hero_id := ""

func configure(profile: BotDifficultyProfile, hero_id: String) -> void:
	_profile = profile
	_hero_id = hero_id

func build_input_frame(perception: BotPerception, tick: int, sequence: int, ability_by_slot: Dictionary) -> InputFrame:
	var decision := _decide(perception, tick)
	return BotInputBuilder.build(perception.self_player_id, decision, tick, sequence, ability_by_slot)

func _decide(perception: BotPerception, tick: int) -> BotDecision:
	var decision := BotDecision.new()
	var objective := BotObjectiveSelector.select_objective(perception, _profile)
	var self_pos := Vector2(float(perception.map_hints.get("self_x", 0.0)), float(perception.map_hints.get("self_y", 0.0)))
	var target := BotThreatEvaluator.nearest_enemy(perception)
	if objective == "retreat_to_safe_zone":
		var center := Vector2.ZERO
		decision.move_direction = Steering.direction_to(center, self_pos)
		decision.aim_direction = decision.move_direction if decision.move_direction.length() > 0.0 else Vector2.RIGHT
		decision.debug_reason = "low_health_retreat"
		return decision
	if not target.is_empty():
		var target_pos := Vector2(float(target.get("x", 0.0)), float(target.get("y", 0.0)))
		var direction := Steering.direction_to(self_pos, target_pos)
		decision.aim_direction = direction
		decision.move_direction = direction if float(target.get("distance", 999.0)) > 150.0 else Vector2(-direction.y, direction.x) * 0.45
		decision.desired_target_entity_id = int(target.get("entity_id", 0))
		decision.desired_target_position = target_pos
		if tick % max(1, _profile.reaction_delay_ticks) == 0:
			decision.cast_slot = BotAbilityScorer.choose_slot(perception, _profile, float(target.get("distance", 999.0)))
		decision.debug_reason = "pressure_target"
		return decision
	decision.move_direction = Steering.direction_to(self_pos, Vector2.ZERO)
	decision.aim_direction = decision.move_direction if decision.move_direction.length() > 0.0 else Vector2.RIGHT
	decision.debug_reason = "return_center"
	return decision
