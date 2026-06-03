class_name InputFrame
extends RefCounted

var player_id := ""
var input_sequence := 0
var client_tick := 0
var move_x := 0.0
var move_y := 0.0
var aim_x := 1.0
var aim_y := 0.0
var buttons: Dictionary = {
	GameConstants.SLOT_BASIC: false,
	GameConstants.SLOT_ABILITY_1: false,
	GameConstants.SLOT_ABILITY_2: false,
	GameConstants.SLOT_ULTIMATE: false,
	"interact": false,
}
var cast_requests: Array[Dictionary] = []

func normalized() -> InputFrame:
	var copy := InputFrame.new()
	copy.player_id = player_id
	copy.input_sequence = max(input_sequence, 0)
	copy.client_tick = max(client_tick, 0)
	var move := Vector2(_finite_or_zero(move_x), _finite_or_zero(move_y))
	if move.length() > 1.0:
		move = move.normalized()
	copy.move_x = clampf(move.x, -1.0, 1.0)
	copy.move_y = clampf(move.y, -1.0, 1.0)
	var aim := Vector2(_finite_or_zero(aim_x), _finite_or_zero(aim_y))
	if aim.length_squared() <= 0.0001:
		aim = Vector2.RIGHT
	elif aim.length() > 1.0:
		aim = aim.normalized()
	copy.aim_x = clampf(aim.x, -1.0, 1.0)
	copy.aim_y = clampf(aim.y, -1.0, 1.0)
	copy.buttons = buttons.duplicate(true)
	copy.cast_requests = cast_requests.duplicate(true)
	return copy

func is_valid() -> bool:
	return player_id != "" and input_sequence >= 0 and client_tick >= 0 and is_finite(move_x) and is_finite(move_y) and is_finite(aim_x) and is_finite(aim_y)

func to_dict() -> Dictionary:
	return {
		"player_id": player_id,
		"input_sequence": input_sequence,
		"client_tick": client_tick,
		"move": {"x": move_x, "y": move_y},
		"aim": {"x": aim_x, "y": aim_y},
		"buttons": buttons,
		"cast_requests": cast_requests,
	}

static func from_dict(data: Dictionary) -> InputFrame:
	var frame := InputFrame.new()
	frame.player_id = str(data.get("player_id", ""))
	frame.input_sequence = int(data.get("input_sequence", 0))
	frame.client_tick = int(data.get("client_tick", 0))
	var move: Dictionary = data.get("move", {})
	var aim: Dictionary = data.get("aim", {})
	frame.move_x = float(move.get("x", data.get("move_x", 0.0)))
	frame.move_y = float(move.get("y", data.get("move_y", 0.0)))
	frame.aim_x = float(aim.get("x", data.get("aim_x", 1.0)))
	frame.aim_y = float(aim.get("y", data.get("aim_y", 0.0)))
	frame.buttons = data.get("buttons", {}).duplicate(true)
	frame.cast_requests.clear()
	for request in data.get("cast_requests", []):
		if typeof(request) == TYPE_DICTIONARY:
			frame.cast_requests.append((request as Dictionary).duplicate(true))
	return frame.normalized()

static func _finite_or_zero(value: float) -> float:
	if not is_finite(value):
		return 0.0
	return value
