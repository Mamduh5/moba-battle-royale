class_name ClientSession
extends RefCounted

var player_id := ""
var nakama_user_id := ""
var display_name := ""
var selected_hero_id := GameConstants.DEFAULT_HERO
var team_id := GameConstants.TEAM_NONE
var match_token := ""
var connected := true
var is_bot := false
var last_input_sequence := 0

static func human(id: String, hero_id: String, team: int = GameConstants.TEAM_NONE) -> ClientSession:
	var session := ClientSession.new()
	session.player_id = id
	session.nakama_user_id = "local_%s" % id
	session.display_name = id
	session.selected_hero_id = hero_id
	session.team_id = team
	session.match_token = "dev-token-%s" % id
	session.is_bot = false
	return session

static func bot(id: String, hero_id: String, team: int) -> ClientSession:
	var session := ClientSession.new()
	session.player_id = id
	session.nakama_user_id = "bot_%s" % id
	session.display_name = id.capitalize()
	session.selected_hero_id = hero_id
	session.team_id = team
	session.match_token = "bot-token-%s" % id
	session.is_bot = true
	return session
