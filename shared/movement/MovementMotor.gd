class_name MovementMotor
extends RefCounted

static func move_entity(entity: Dictionary, input: InputFrame, delta: float, map_def: MapDef) -> Dictionary:
	var speed := float(entity.get("move_speed", 240.0))
	var direction := Vector2(input.move_x, input.move_y)
	if direction.length() > 1.0:
		direction = direction.normalized()
	var position := _dict_to_vec2(entity.get("position", {}))
	var velocity := direction * speed
	var next_position := position + velocity * delta
	next_position = _clamp_to_bounds(next_position, map_def.get_bounds_rect())
	for obstacle in map_def.obstacles:
		var rect := Rect2(float(obstacle.get("x", 0.0)), float(obstacle.get("y", 0.0)), float(obstacle.get("w", 0.0)), float(obstacle.get("h", 0.0)))
		if rect.grow(18.0).has_point(next_position):
			next_position = position
			velocity = Vector2.ZERO
			break
	var aim := Vector2(input.aim_x, input.aim_y)
	if aim.length() == 0.0:
		aim = Vector2.RIGHT
	aim = aim.normalized()
	return {
		"position": {"x": next_position.x, "y": next_position.y},
		"velocity": {"x": velocity.x, "y": velocity.y},
		"facing": {"x": aim.x, "y": aim.y},
	}

static func _clamp_to_bounds(position: Vector2, bounds: Rect2) -> Vector2:
	return Vector2(clampf(position.x, bounds.position.x + 24.0, bounds.end.x - 24.0), clampf(position.y, bounds.position.y + 24.0, bounds.end.y - 24.0))

static func _dict_to_vec2(data: Dictionary) -> Vector2:
	return Vector2(float(data.get("x", 0.0)), float(data.get("y", 0.0)))
