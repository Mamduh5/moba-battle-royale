class_name BotDifficultyProfile
extends RefCounted

var profile_id := ""
var reaction_delay_ticks := 4
var aim_error_degrees := 0.0
var aggression := 0.5
var objective_priority := 0.5
var retreat_health_ratio := 0.3
var skill_usage := 0.6
var dodge_skill := 0.4
var map_awareness := 0.5

static func from_def(def: BotProfileDef) -> BotDifficultyProfile:
	var profile := BotDifficultyProfile.new()
	if def == null:
		return profile
	profile.profile_id = def.id
	profile.reaction_delay_ticks = def.reaction_delay_ticks
	profile.aim_error_degrees = def.aim_error_degrees
	profile.aggression = def.aggression
	profile.objective_priority = def.objective_priority
	profile.retreat_health_ratio = def.retreat_health_ratio
	profile.skill_usage = def.skill_usage
	profile.dodge_skill = def.dodge_skill
	profile.map_awareness = def.map_awareness
	return profile
