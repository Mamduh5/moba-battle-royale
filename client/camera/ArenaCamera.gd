class_name ArenaCamera
extends Camera2D

var target: Node2D = null
var bounds := Rect2(Vector2(-1200, -760), Vector2(2400, 1520))

func _ready() -> void:
	zoom = Vector2(0.72, 0.72)
	position_smoothing_enabled = true
	position_smoothing_speed = 8.0

func _process(_delta: float) -> void:
	if target != null:
		position = target.global_position
	else:
		position = Vector2.ZERO
