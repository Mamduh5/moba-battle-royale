class_name CollisionQuery
extends RefCounted

static func point_inside_obstacle(point: Vector2, map_def: MapDef, padding: float = 0.0) -> bool:
	for obstacle in map_def.obstacles:
		var rect := Rect2(float(obstacle.get("x", 0.0)), float(obstacle.get("y", 0.0)), float(obstacle.get("w", 0.0)), float(obstacle.get("h", 0.0))).grow(padding)
		if rect.has_point(point):
			return true
	return false
