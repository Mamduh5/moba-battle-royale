class_name MapDef
extends RefCounted

var id := ""
var display_name := ""
var bounds: Dictionary = {}
var obstacles: Array = []
var objective_points: Array = []
var spawn_points: Array = []
var floor_color := "#17323A"
var line_color := "#45A6A6"
var wall_color := "#244B57"
var spawn_color := "#F4D35E"
var raw: Dictionary = {}

static func from_dict(data: Dictionary) -> MapDef:
	var def := MapDef.new()
	def.raw = data.duplicate(true)
	def.id = str(data.get("id", ""))
	def.display_name = str(data.get("display_name", def.id))
	def.bounds = data.get("bounds", {}).duplicate(true)
	def.obstacles = data.get("obstacles", []).duplicate(true)
	def.objective_points = data.get("objective_points", []).duplicate(true)
	def.spawn_points = data.get("spawn_points", []).duplicate(true)
	def.floor_color = str(data.get("floor_color", def.floor_color))
	def.line_color = str(data.get("line_color", def.line_color))
	def.wall_color = str(data.get("wall_color", def.wall_color))
	def.spawn_color = str(data.get("spawn_color", def.spawn_color))
	return def

func get_bounds_rect() -> Rect2:
	return Rect2(
		Vector2(float(bounds.get("x", -1000.0)), float(bounds.get("y", -600.0))),
		Vector2(float(bounds.get("width", 2000.0)), float(bounds.get("height", 1200.0)))
	)

func get_spawn_position(spawn_id: String) -> Vector2:
	for spawn in spawn_points:
		if str(spawn.get("id", "")) == spawn_id:
			return Vector2(float(spawn.get("x", 0.0)), float(spawn.get("y", 0.0)))
	return Vector2.ZERO
