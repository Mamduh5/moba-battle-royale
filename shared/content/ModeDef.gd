class_name ModeDef
extends RefCounted

var id := ""
var display_name := ""
var mode_type := ""
var map_id := ""
var team_based := false
var teams: Array = []
var team_size := 0
var max_participants := 0
var min_humans := 1
var bot_fill := true
var score_limit := 0
var duration_sec := 0
var respawn_sec := 0.0
var invulnerability_sec := 0.0
var kill_score := 1
var friendly_fire := false
var bot_profile_id := ""
var friend_team_mode := "split"
var raw: Dictionary = {}

static func from_dict(data: Dictionary) -> ModeDef:
	var def := ModeDef.new()
	def.raw = data.duplicate(true)
	def.id = str(data.get("id", ""))
	def.display_name = str(data.get("display_name", def.id))
	def.mode_type = str(data.get("mode_type", ""))
	def.map_id = str(data.get("map_id", ""))
	def.team_based = bool(data.get("team_based", false))
	def.teams = data.get("teams", []).duplicate(true)
	def.team_size = int(data.get("team_size", 0))
	def.max_participants = int(data.get("max_participants", 0))
	def.min_humans = int(data.get("min_humans", 1))
	def.bot_fill = bool(data.get("bot_fill", true))
	def.score_limit = int(data.get("score_limit", 0))
	def.duration_sec = int(data.get("duration_sec", 0))
	def.respawn_sec = float(data.get("respawn_sec", 3.0))
	def.invulnerability_sec = float(data.get("invulnerability_sec", 1.0))
	def.kill_score = int(data.get("kill_score", 1))
	def.friendly_fire = bool(data.get("friendly_fire", false))
	def.bot_profile_id = str(data.get("bot_profile_id", ""))
	def.friend_team_mode = str(data.get("friend_team_mode", "split"))
	return def
