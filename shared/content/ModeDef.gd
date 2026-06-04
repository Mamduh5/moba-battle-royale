class_name ModeDef
extends RefCounted

var id := ""
var display_name := ""
var mode_type := ""
var map_id := ""
var max_participants := 0
var teams_enabled := false
var team_count := 0
var team_size := 0
var bot_fill := true
var score_limit := 0
var duration_sec := 0
var respawn_delay_sec := 0.0
var invulnerability_sec := 0.0
var friendly_fire := false
var score: Dictionary = {}

static func from_dict(data: Dictionary) -> ModeDef:
	var mode := ModeDef.new()
	mode.id = str(data.get("id", ""))
	mode.display_name = str(data.get("display_name", mode.id))
	mode.mode_type = str(data.get("mode_type", ""))
	mode.map_id = str(data.get("map_id", ""))
	mode.max_participants = int(data.get("max_participants", 0))
	mode.teams_enabled = bool(data.get("teams_enabled", false))
	mode.team_count = int(data.get("team_count", 0))
	mode.team_size = int(data.get("team_size", 0))
	mode.bot_fill = bool(data.get("bot_fill", true))
	mode.score_limit = int(data.get("score_limit", 0))
	mode.duration_sec = int(data.get("duration_sec", 0))
	mode.respawn_delay_sec = float(data.get("respawn_delay_sec", 0.0))
	mode.invulnerability_sec = float(data.get("invulnerability_sec", 0.0))
	mode.friendly_fire = bool(data.get("friendly_fire", false))
	mode.score = data.get("score", {}).duplicate(true)
	return mode
