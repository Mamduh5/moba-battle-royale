class_name CollisionQuery
extends RefCounted

static func solve_position(previous: Vector2, desired: Vector2, radius: float, map_def: MapDef) -> Vector2:
	if map_def == null:
		return desired
	var clamped := clamp_to_bounds(desired, radius, map_def)
	if is_inside_obstacle(clamped, radius, map_def):
		var slide_x := Vector2(clamped.x, previous.y)
		if not is_inside_obstacle(slide_x, radius, map_def):
			return clamp_to_bounds(slide_x, radius, map_def)
		var slide_y := Vector2(previous.x, clamped.y)
		if not is_inside_obstacle(slide_y, radius, map_def):
			return clamp_to_bounds(slide_y, radius, map_def)
		return previous
	return clamped

static func clamp_to_bounds(position: Vector2, radius: float, map_def: MapDef) -> Vector2:
	var bounds := map_def.get_bounds_rect()
	return Vector2(
		clampf(position.x, bounds.position.x + radius, bounds.position.x + bounds.size.x - radius),
		clampf(position.y, bounds.position.y + radius, bounds.position.y + bounds.size.y - radius)
	)

static func is_inside_obstacle(position: Vector2, radius: float, map_def: MapDef) -> bool:
	for obstacle in map_def.obstacles:
		var rect := Rect2(
			Vector2(float(obstacle.get("x", 0.0)), float(obstacle.get("y", 0.0))),
			Vector2(float(obstacle.get("width", 0.0)), float(obstacle.get("height", 0.0)))
		).grow(radius)
		if rect.has_point(position):
			return true
	return false

static func is_position_safe(position: Vector2, radius: float, map_def: MapDef) -> bool:
	if map_def == null:
		return true
	var bounds := map_def.get_bounds_rect().grow(-radius)
	return bounds.has_point(position) and not is_inside_obstacle(position, radius, map_def)
