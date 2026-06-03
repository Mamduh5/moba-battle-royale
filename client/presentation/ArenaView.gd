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
	draw_rect(bounds, Color(str(map_def.floor_color)), true)
	draw_rect(bounds, Color(str(map_def.line_color)), false, 5.0)
	var grid_color := Color(str(map_def.line_color))
	grid_color.a = 0.15
	for x in range(int(bounds.position.x), int(bounds.position.x + bounds.size.x), 160):
		draw_line(Vector2(x, bounds.position.y), Vector2(x, bounds.position.y + bounds.size.y), grid_color, 1.0)
	for y in range(int(bounds.position.y), int(bounds.position.y + bounds.size.y), 160):
		draw_line(Vector2(bounds.position.x, y), Vector2(bounds.position.x + bounds.size.x, y), grid_color, 1.0)
	for obstacle in map_def.obstacles:
		var rect := Rect2(Vector2(float(obstacle.get("x", 0.0)), float(obstacle.get("y", 0.0))), Vector2(float(obstacle.get("width", 0.0)), float(obstacle.get("height", 0.0))))
		draw_rect(rect, Color(str(map_def.wall_color)), true)
		draw_rect(rect, Color(0.65, 0.95, 0.95, 0.32), false, 3.0)
	for spawn in map_def.spawn_points:
		var pos := Vector2(float(spawn.get("x", 0.0)), float(spawn.get("y", 0.0)))
		var spawn_color := Color(str(map_def.spawn_color))
		spawn_color.a = 0.18
		draw_circle(pos, 28.0, spawn_color)
	for objective in map_def.objective_points:
		var pos := Vector2(float(objective.get("x", 0.0)), float(objective.get("y", 0.0)))
		draw_arc(pos, 42.0, 0.0, TAU, 36, Color(1.0, 0.9, 0.25, 0.55), 3.0)
