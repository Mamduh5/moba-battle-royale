class_name SimulationConfig
extends RefCounted

var tick_rate := 30
var fixed_delta := 1.0 / 30.0
var mode_id := ""
var map_id := ""
var mode_def: ModeDef = null
var map_def: MapDef = null
var match_duration_ticks := 0
var respawn_ticks := 90
var invulnerability_ticks := 30
var score_limit := 0
var kill_score := 1
var friendly_fire := false
var team_based := false

static func from_defs(mode: ModeDef, map: MapDef, rate: int = 30) -> SimulationConfig:
	var config := SimulationConfig.new()
	config.tick_rate = max(rate, 1)
	config.fixed_delta = 1.0 / float(config.tick_rate)
	config.mode_def = mode
	config.map_def = map
	if mode != null:
		config.mode_id = mode.id
		config.map_id = mode.map_id
		config.match_duration_ticks = int(mode.duration_sec * config.tick_rate)
		config.respawn_ticks = int(mode.respawn_sec * config.tick_rate)
		config.invulnerability_ticks = int(mode.invulnerability_sec * config.tick_rate)
		config.score_limit = mode.score_limit
		config.kill_score = mode.kill_score
		config.friendly_fire = mode.friendly_fire
		config.team_based = mode.team_based
	if map != null:
		config.map_id = map.id
	return config
