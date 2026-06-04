extends RefCounted

func run() -> Array[String]:
	var errors: Array[String] = []
	var room := MatchRoom.new()
	room.configure({"match_id": "fixture", "mode_id": "3v3_team_arena"}, ContentDB)
	room.start_match()
	if room.get_bot_count() != 6:
		errors.append("bot fill failed")
	return errors
