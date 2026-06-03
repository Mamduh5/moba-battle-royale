class_name ArenaView
extends Node2D

var map_def: MapDef = null

func setup(map: MapDef) -> void:
	map_def = map
	queue_redraw()

func _draw() -> void:
	if map_def == null:
		return
	var bounds := map_def.get_bounds_rect()
	var floor := Color(str(map_def.floor_color))
	var line := Color(str(map_def.line_color))
	draw_rect(bounds.grow(720), Color(0.015, 0.030, 0.036, 1.0), true)
	draw_rect(bounds, floor, true)
	draw_rect(bounds, Color(0.055, 0.165, 0.180, 0.28), false, 18.0)
	draw_rect(bounds, line, false, 5.0)
	var inner := bounds.grow(-92.0)
	draw_rect(inner, Color(0.040, 0.105, 0.118, 0.34), false, 3.0)
	draw_line(Vector2(bounds.position.x, 0), Vector2(bounds.position.x + bounds.size.x, 0), Color(line.r, line.g, line.b, 0.18), 4.0)
	draw_line(Vector2(0, bounds.position.y), Vector2(0, bounds.position.y + bounds.size.y), Color(line.r, line.g, line.b, 0.18), 4.0)
	var grid_color := Color(str(map_def.line_color))
	grid_color.a = 0.11
	for x in range(int(bounds.position.x), int(bounds.position.x + bounds.size.x), 160):
		draw_line(Vector2(x, bounds.position.y), Vector2(x, bounds.position.y + bounds.size.y), grid_color, 1.0)
	for y in range(int(bounds.position.y), int(bounds.position.y + bounds.size.y), 160):
		draw_line(Vector2(bounds.position.x, y), Vector2(bounds.position.x + bounds.size.x, y), grid_color, 1.0)
	for i in range(14):
		var start := Vector2(bounds.position.x + i * 180.0, bounds.position.y)
		draw_line(start, start + Vector2(-420, bounds.size.y), Color(0.950, 0.750, 0.250, 0.045), 2.0)
	for obstacle in map_def.obstacles:
		var rect := Rect2(Vector2(float(obstacle.get("x", 0.0)), float(obstacle.get("y", 0.0))), Vector2(float(obstacle.get("width", 0.0)), float(obstacle.get("height", 0.0))))
		draw_rect(Rect2(rect.position + Vector2(8, 10), rect.size), Color(0.0, 0.0, 0.0, 0.28), true)
		draw_rect(rect, Color(str(map_def.wall_color)), true)
		draw_rect(Rect2(rect.position + Vector2(8, 8), rect.size - Vector2(16, 16)), Color(0.070, 0.175, 0.195, 0.84), true)
		draw_rect(rect, Color(0.65, 0.95, 0.95, 0.40), false, 3.0)
		draw_line(rect.position + Vector2(12, 12), rect.position + Vector2(rect.size.x - 12, 12), Color(1.0, 1.0, 1.0, 0.12), 2.0)
	for spawn in map_def.spawn_points:
		var pos := Vector2(float(spawn.get("x", 0.0)), float(spawn.get("y", 0.0)))
		var spawn_color := Color(str(map_def.spawn_color))
		var team_id := int(spawn.get("team_id", 0))
		if team_id == GameConstants.TEAM_A:
			spawn_color = Color(0.230, 0.630, 1.000)
		elif team_id == GameConstants.TEAM_B:
			spawn_color = Color(1.000, 0.330, 0.270)
		spawn_color.a = 0.18
		draw_circle(pos, 36.0, spawn_color)
		draw_arc(pos, 42.0, 0.0, TAU, 36, Color(spawn_color.r, spawn_color.g, spawn_color.b, 0.48), 2.0)
		draw_line(pos + Vector2(-18, 0), pos + Vector2(18, 0), Color(spawn_color.r, spawn_color.g, spawn_color.b, 0.45), 2.0)
		draw_line(pos + Vector2(0, -18), pos + Vector2(0, 18), Color(spawn_color.r, spawn_color.g, spawn_color.b, 0.45), 2.0)
	for objective in map_def.objective_points:
		var pos := Vector2(float(objective.get("x", 0.0)), float(objective.get("y", 0.0)))
		draw_circle(pos, 52.0, Color(1.0, 0.76, 0.25, 0.07))
		draw_arc(pos, 52.0, 0.0, TAU, 44, Color(1.0, 0.9, 0.25, 0.58), 3.0)
		draw_arc(pos, 30.0, 0.0, TAU, 32, Color(0.300, 0.930, 0.880, 0.38), 2.0)
		draw_colored_polygon(PackedVector2Array([pos + Vector2(0, -18), pos + Vector2(18, 0), pos + Vector2(0, 18), pos + Vector2(-18, 0)]), Color(1.0, 0.76, 0.25, 0.16))
