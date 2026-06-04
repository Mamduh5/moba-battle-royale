class_name BotInputBuilder
extends RefCounted

static func build(player_id: String, decision: BotDecision, tick: int, sequence: int, ability_by_slot: Dictionary) -> InputFrame:
	var frame := InputFrame.new()
	frame.player_id = player_id
	frame.input_sequence = sequence
	frame.client_tick = tick
	frame.move_x = decision.move_direction.x
	frame.move_y = decision.move_direction.y
	frame.aim_x = decision.aim_direction.x
	frame.aim_y = decision.aim_direction.y
	frame.buttons = {
		GameConstants.SLOT_BASIC: decision.cast_slot == GameConstants.SLOT_BASIC,
		GameConstants.SLOT_ABILITY_1: decision.cast_slot == GameConstants.SLOT_ABILITY_1,
		GameConstants.SLOT_ULTIMATE: decision.cast_slot == GameConstants.SLOT_ULTIMATE,
	}
	if decision.cast_slot != "" and ability_by_slot.has(decision.cast_slot):
		frame.cast_requests.append({
			"slot": decision.cast_slot,
			"ability_id": str(ability_by_slot[decision.cast_slot]),
			"target_entity_id": decision.desired_target_entity_id,
			"target_position": {"x": decision.desired_target_position.x, "y": decision.desired_target_position.y},
			"aim": {"x": decision.aim_direction.x, "y": decision.aim_direction.y},
		})
	return frame.normalized()
