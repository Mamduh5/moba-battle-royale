class_name BotProfileDef
extends RefCounted

var id := ""
var display_name := ""
var reaction_delay_ticks := 4
var aim_error_degrees := 0.0
var aggression := 0.5
var objective_priority := 0.5
var retreat_health_ratio := 0.3
var skill_usage := 0.6
var dodge_skill := 0.4
var map_awareness := 0.5
var hero_pool: Array = []
var raw: Dictionary = {}

static func from_dict(data: Dictionary) -> BotProfileDef:
	var def := BotProfileDef.new()
	def.raw = data.duplicate(true)
	def.id = str(data.get("id", ""))
	def.display_name = str(data.get("display_name", def.id))
	def.reaction_delay_ticks = int(data.get("reaction_delay_ticks", 4))
	def.aim_error_degrees = float(data.get("aim_error_degrees", 0.0))
	def.aggression = float(data.get("aggression", 0.5))
	def.objective_priority = float(data.get("objective_priority", 0.5))
	def.retreat_health_ratio = float(data.get("retreat_health_ratio", 0.3))
	def.skill_usage = float(data.get("skill_usage", 0.6))
	def.dodge_skill = float(data.get("dodge_skill", 0.4))
	def.map_awareness = float(data.get("map_awareness", 0.5))
	def.hero_pool = data.get("hero_pool", []).duplicate(true)
	return def
