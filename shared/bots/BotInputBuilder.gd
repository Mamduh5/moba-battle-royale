class_name BotInputBuilder
extends RefCounted

func build(player_id: String, tick: int, sequence: int, decision: BotDecision, ability_slots: Dictionary) -> InputFrame:
	var frame := InputFrame.new()
	frame.player_id = player_id
	frame.input_sequence = sequence
	frame.client_tick = tick
	frame.move_x = decision.move_direction.x
	frame.move_y = decision.move_direction.y
	frame.aim_x = decision.aim_direction.x
	frame.aim_y = decision.aim_direction.y
	frame.buttons[GameConstants.SLOT_BASIC] = false
	frame.buttons[GameConstants.SLOT_ABILITY_1] = false
	frame.buttons[GameConstants.SLOT_ABILITY_2] = false
	frame.buttons[GameConstants.SLOT_ULTIMATE] = false
	if decision.cast_slot != "":
		frame.buttons[decision.cast_slot] = true
		frame.cast_requests.append({
			"slot": decision.cast_slot,
			"ability_id": str(ability_slots.get(decision.cast_slot, "")),
			"target_entity_id": decision.desired_target_entity_id,
			"target_position": {"x": decision.desired_target_position.x, "y": decision.desired_target_position.y},
			"aim": {"x": decision.aim_direction.x, "y": decision.aim_direction.y},
		})
	frame.buttons["interact"] = decision.interact
	return frame.normalized()
