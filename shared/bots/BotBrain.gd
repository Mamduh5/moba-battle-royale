class_name BotBrain
extends RefCounted

var _profile := BotDifficultyProfile.new()
var _hero_id := ""
var _input_builder := BotInputBuilder.new()
var _objective_selector := BotObjectiveSelector.new()
var _ability_scorer := BotAbilityScorer.new()
var _threats := BotThreatEvaluator.new()

func configure(profile: BotDifficultyProfile, hero_id: String) -> void:
	_profile = profile
	_hero_id = hero_id

func build_input_frame(perception: BotPerception, tick: int, sequence: int) -> InputFrame:
	var decision := BotDecision.new()
	var self_pos: Vector2 = perception.self_entity.get("position", Vector2.ZERO)
	var objective := _objective_selector.choose_objective(perception, _profile)
	var nearest := _threats.nearest_enemy(perception)
	if not nearest.is_empty():
		var target_pos: Vector2 = nearest.get("position", self_pos)
		decision.desired_target_entity_id = int(nearest.get("entity_id", 0))
		decision.desired_target_position = target_pos
		var toward := Steering.direction_to(self_pos, target_pos)
		decision.aim_direction = toward if toward != Vector2.ZERO else Vector2.RIGHT
		match objective:
			"retreat_to_safe_zone":
				decision.move_direction = Steering.flee(self_pos, target_pos)
				decision.cast_slot = GameConstants.SLOT_ABILITY_1 if CooldownTracker.is_ready(perception.self_entity, GameConstants.SLOT_ABILITY_1) else ""
				decision.debug_reason = "low_health_retreat"
			"kite_enemy":
				decision.move_direction = (Steering.flee(self_pos, target_pos) + Steering.orbit(self_pos, target_pos, true) * 0.45).normalized()
				decision.cast_slot = _ability_scorer.choose_slot(perception, _profile, nearest)
				decision.debug_reason = "kite_enemy"
			_:
				decision.move_direction = toward
				decision.cast_slot = _ability_scorer.choose_slot(perception, _profile, nearest)
				decision.debug_reason = "attack_enemy"
	else:
		var center := Vector2.ZERO
		if not perception.objectives.is_empty():
			var objective_point: Dictionary = perception.objectives[0]
			center = Vector2(float(objective_point.get("x", 0.0)), float(objective_point.get("y", 0.0)))
		decision.move_direction = Steering.direction_to(self_pos, center)
		decision.aim_direction = decision.move_direction if decision.move_direction != Vector2.ZERO else Vector2.RIGHT
		decision.debug_reason = "seek_objective"
	var ability_slots: Dictionary = perception.self_entity.get("ability_slots", {})
	return _input_builder.build(str(perception.self_entity.get("owner_player_id", "")), tick, sequence, decision, ability_slots)
