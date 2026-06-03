class_name HeroDef
extends RefCounted

var id := ""
var display_name := ""
var role := ""
var stats: Dictionary = {}
var visual: Dictionary = {}
var ability_slots: Dictionary = {}
var raw: Dictionary = {}

static func from_dict(data: Dictionary) -> HeroDef:
	var def := HeroDef.new()
	def.raw = data.duplicate(true)
	def.id = str(data.get("id", ""))
	def.display_name = str(data.get("display_name", def.id))
	def.role = str(data.get("role", "fighter"))
	def.stats = data.get("stats", {}).duplicate(true)
	def.visual = data.get("visual", {}).duplicate(true)
	def.ability_slots = data.get("ability_slots", {}).duplicate(true)
	return def

func get_max_health() -> int:
	return int(stats.get("max_health", 1000))

func get_move_speed() -> float:
	return float(stats.get("move_speed", 170.0))

func get_radius() -> float:
	return float(stats.get("radius", 16.0))

func get_armor() -> float:
	return clampf(float(stats.get("armor", 0.0)), 0.0, 0.85)
