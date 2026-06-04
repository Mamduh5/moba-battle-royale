class_name BotDifficultyProfile
extends RefCounted

var profile_id := ""
var reaction_delay_ticks := 4
var aim_error_degrees := 0.0
var aggression := 0.5
var objective_priority := 0.5
var retreat_health_ratio := 0.25
var skill_usage := 0.7
var dodge_skill := 0.5
var map_awareness := 0.75

static func from_profile_def(profile: BotProfileDef) -> BotDifficultyProfile:
	var out := BotDifficultyProfile.new()
	out.profile_id = profile.id
	out.reaction_delay_ticks = profile.reaction_delay_ticks
	out.aim_error_degrees = profile.aim_error_degrees
	out.aggression = profile.aggression
	out.objective_priority = profile.objective_priority
	out.retreat_health_ratio = profile.retreat_health_ratio
	out.skill_usage = profile.skill_usage
	out.dodge_skill = profile.dodge_skill
	out.map_awareness = profile.map_awareness
	return out
