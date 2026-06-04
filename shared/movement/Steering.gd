class_name Steering
extends RefCounted

static func direction_to(from_position: Vector2, to_position: Vector2) -> Vector2:
	var delta := to_position - from_position
	if delta.length() == 0.0:
		return Vector2.ZERO
	return delta.normalized()
