class_name MobileInputAdapter
extends RefCounted

var move_vector := Vector2.ZERO
var aim_vector := Vector2.RIGHT
var buttons: Dictionary = {}

func set_move_vector(value: Vector2) -> void:
	move_vector = value.limit_length(1.0)

func set_aim_vector(value: Vector2) -> void:
	aim_vector = value.normalized() if value.length_squared() > 0.001 else Vector2.RIGHT

func set_button_pressed(action: String, pressed: bool) -> void:
	buttons[action] = pressed

func get_move_vector() -> Vector2:
	return move_vector

func get_aim_vector(_viewport: Viewport, _origin_screen: Vector2) -> Vector2:
	return aim_vector

func is_button_down(action: String) -> bool:
	return bool(buttons.get(action, false))

func is_button_just_pressed(action: String) -> bool:
	return bool(buttons.get(action, false))
