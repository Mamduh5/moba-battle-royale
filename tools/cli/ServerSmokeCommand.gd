class_name ServerSmokeCommand
extends RefCounted

func run(_args: Dictionary, content_db: Object) -> int:
	content_db.load_all()
	var errors: Array[String] = content_db.validate_all()
	if not errors.is_empty():
		for error in errors:
			printerr("server_smoke_content_error: %s" % error)
		return ProtocolConstants.EXIT_CONTENT_VALIDATION_FAILURE
	var failures: Array[String] = []
	_smoke_room(content_db, GameConstants.MODE_TEAM_ARENA, 1, failures)
	_smoke_room(content_db, GameConstants.MODE_TEAM_ARENA, 2, failures)
	_smoke_room(content_db, GameConstants.MODE_DEATHMATCH, 2, failures)
	if not failures.is_empty():
		for failure in failures:
			printerr("server_smoke_failure: %s" % failure)
		return ProtocolConstants.EXIT_SERVER_BOOT_FAILURE
	print("server-smoke: ok checks=1human+bots,2human+team_bots,2human+deathmatch_bots")
	return ProtocolConstants.EXIT_SUCCESS

func _smoke_room(db: Object, mode_id: String, humans: int, failures: Array[String]) -> void:
	var room := MatchRoom.new()
	room.configure({"mode_id": mode_id, "match_id": "smoke_%s_%d" % [mode_id, humans], "seed": 8100 + humans}, db)
	var hero_ids := ["hero_guardian", "hero_shade", "hero_arcanist"]
	for i in range(humans):
		room.add_session(ClientSession.human("player_%02d" % (i + 1), hero_ids[i % hero_ids.size()]))
	room.start_match()
	var roster := room.get_roster()
	var mode: ModeDef = db.get_mode(mode_id)
	if roster.size() != mode.max_participants:
		failures.append("%s humans=%d roster expected %d got %d" % [mode_id, humans, mode.max_participants, roster.size()])
	var bot_count := 0
	for entry in roster:
		if bool(entry.get("is_bot", false)):
			bot_count += 1
	if bot_count != mode.max_participants - humans:
		failures.append("%s humans=%d bot fill expected %d got %d" % [mode_id, humans, mode.max_participants - humans, bot_count])
	for _i in range(90):
		room.tick(1.0 / 30.0)
	var snapshot := room.get_last_snapshot()
	if snapshot.entities.is_empty():
		failures.append("%s humans=%d produced empty snapshot" % [mode_id, humans])
