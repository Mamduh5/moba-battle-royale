class_name InputSampler
extends RefCounted

var _adapter: Object = null

func sample(player_id: String, client_tick: int, sequence: int) -> InputFrame:
	if _adapter != null and _adapter.has_method("sample"):
		return _adapter.sample(player_id, client_tick, sequence)
	var frame := InputFrame.new()
	frame.player_id = player_id
	frame.client_tick = client_tick
	frame.input_sequence = sequence
	var move := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if move.length() > 1.0:
		move = move.normalized()
	frame.move_x = move.x
	frame.move_y = move.y
	var tree := Engine.get_main_loop() as SceneTree
	var viewport := tree.root
	var center := viewport.get_visible_rect().size * 0.5
	var aim := (viewport.get_mouse_position() - center)
	if aim.length() == 0.0:
		aim = Vector2.RIGHT
	aim = aim.normalized()
	frame.aim_x = aim.x
	frame.aim_y = aim.y
	frame.buttons = {
		GameConstants.SLOT_BASIC: Input.is_action_pressed("basic_attack"),
		GameConstants.SLOT_ABILITY_1: Input.is_action_just_pressed("ability_1"),
		GameConstants.SLOT_ULTIMATE: Input.is_action_just_pressed("ultimate"),
	}
	return frame.normalized()

func set_input_adapter(adapter: Object) -> void:
	_adapter = adapter
