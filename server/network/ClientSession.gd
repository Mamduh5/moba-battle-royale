class_name ClientSession
extends RefCounted

var player_id := ""
var nakama_user_id := ""
var display_name := ""
var selected_hero_id := "hero_guardian"
var team_id := GameConstants.TEAM_NONE
var is_bot := false
var connected := true
var last_sequence := 0

static func make_human(id: String, hero_id: String, name: String = "") -> ClientSession:
	var session := ClientSession.new()
	session.player_id = id
	session.nakama_user_id = id
	session.display_name = name if name != "" else id
	session.selected_hero_id = hero_id
	session.is_bot = false
	return session

static func make_bot(id: String, hero_id: String, team: int, name: String) -> ClientSession:
	var session := ClientSession.new()
	session.player_id = id
	session.display_name = name
	session.selected_hero_id = hero_id
	session.team_id = team
	session.is_bot = true
	return session
