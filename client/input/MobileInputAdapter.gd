class_name MobileInputAdapter
extends RefCounted

var move_direction := Vector2.ZERO
var aim_direction := Vector2.RIGHT
var buttons: Dictionary = {}

func sample(player_id: String, client_tick: int, sequence: int) -> InputFrame:
	var frame := InputFrame.new()
	frame.player_id = player_id
	frame.client_tick = client_tick
	frame.input_sequence = sequence
	frame.move_x = move_direction.x
	frame.move_y = move_direction.y
	frame.aim_x = aim_direction.x
	frame.aim_y = aim_direction.y
	frame.buttons = buttons.duplicate(true)
	return frame.normalized()
