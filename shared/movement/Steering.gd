class_name Steering
extends RefCounted

static func direction_to(from_position: Vector2, to_position: Vector2) -> Vector2:
	var delta := to_position - from_position
	if delta.length_squared() <= 0.0001:
		return Vector2.ZERO
	return delta.normalized()

static func flee(from_position: Vector2, threat_position: Vector2) -> Vector2:
	return direction_to(threat_position, from_position)

static func orbit(from_position: Vector2, target_position: Vector2, clockwise: bool = true) -> Vector2:
	var toward := direction_to(from_position, target_position)
	if toward == Vector2.ZERO:
		return Vector2.ZERO
	return Vector2(toward.y, -toward.x) if clockwise else Vector2(-toward.y, toward.x)
