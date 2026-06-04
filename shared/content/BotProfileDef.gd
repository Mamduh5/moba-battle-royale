class_name BotProfileDef
extends RefCounted

var id := ""
var display_name := ""
var reaction_delay_ticks := 4
var aim_error_degrees := 0.0
var aggression := 0.5
var objective_priority := 0.5
var retreat_health_ratio := 0.25
var skill_usage := 0.7
var dodge_skill := 0.5
var map_awareness := 0.75
var hero_rotation: Array[String] = []

static func from_dict(data: Dictionary) -> BotProfileDef:
	var profile := BotProfileDef.new()
	profile.id = str(data.get("id", ""))
	profile.display_name = str(data.get("display_name", profile.id))
	profile.reaction_delay_ticks = int(data.get("reaction_delay_ticks", 4))
	profile.aim_error_degrees = float(data.get("aim_error_degrees", 0.0))
	profile.aggression = float(data.get("aggression", 0.5))
	profile.objective_priority = float(data.get("objective_priority", 0.5))
	profile.retreat_health_ratio = float(data.get("retreat_health_ratio", 0.25))
	profile.skill_usage = float(data.get("skill_usage", 0.7))
	profile.dodge_skill = float(data.get("dodge_skill", 0.5))
	profile.map_awareness = float(data.get("map_awareness", 0.75))
	for hero_id in data.get("hero_rotation", []):
		profile.hero_rotation.append(str(hero_id))
	return profile
