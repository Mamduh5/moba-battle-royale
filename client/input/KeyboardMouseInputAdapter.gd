class_name KeyboardMouseInputAdapter
extends RefCounted

var _latched_buttons: Dictionary = {}

func get_move_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func get_aim_vector(viewport: Viewport, origin_screen: Vector2) -> Vector2:
	var mouse := viewport.get_mouse_position()
	var delta := mouse - origin_screen
	if delta.length_squared() <= 0.001:
		return Vector2.RIGHT
	return delta.normalized()

func is_button_down(action: String) -> bool:
	return Input.is_action_pressed(action)

func is_button_just_pressed(action: String) -> bool:
	return Input.is_action_just_pressed(action)

func set_button_pressed(action: String, pressed: bool) -> void:
	_latched_buttons[action] = pressed

func consume_latched(action: String) -> bool:
	var pressed := bool(_latched_buttons.get(action, false))
	_latched_buttons[action] = false
	return pressed
