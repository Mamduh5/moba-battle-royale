class_name ArenaCamera
extends RefCounted

var position := Vector2.ZERO

func follow(target_position: Vector2, weight: float = 0.2) -> void:
	position = position.lerp(target_position, clampf(weight, 0.0, 1.0))
