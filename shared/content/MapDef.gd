class_name MapDef
extends RefCounted

var id := ""
var display_name := ""
var bounds: Dictionary = {}
var floor_palette: Array = []
var wall_color := "#334C68"
var obstacles: Array[Dictionary] = []
var objectives: Array[Dictionary] = []
var spawns: Dictionary = {}

static func from_dict(data: Dictionary) -> MapDef:
	var map_def := MapDef.new()
	map_def.id = str(data.get("id", ""))
	map_def.display_name = str(data.get("display_name", map_def.id))
	map_def.bounds = data.get("bounds", {}).duplicate(true)
	map_def.floor_palette = data.get("floor_palette", []).duplicate(true)
	map_def.wall_color = str(data.get("wall_color", "#334C68"))
	map_def.obstacles.clear()
	for obstacle in data.get("obstacles", []):
		if typeof(obstacle) == TYPE_DICTIONARY:
			map_def.obstacles.append(obstacle.duplicate(true))
	map_def.objectives.clear()
	for objective in data.get("objectives", []):
		if typeof(objective) == TYPE_DICTIONARY:
			map_def.objectives.append(objective.duplicate(true))
	map_def.spawns = data.get("spawns", {}).duplicate(true)
	return map_def

func get_bounds_rect() -> Rect2:
	return Rect2(float(bounds.get("x", -640.0)), float(bounds.get("y", -360.0)), float(bounds.get("w", 1280.0)), float(bounds.get("h", 720.0)))
