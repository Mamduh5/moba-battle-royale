class_name FriendSmokeCommand
extends RefCounted

func run(options: Dictionary = {}) -> int:
	var mode_id := str(options.get("mode", "3v3_team_arena"))
	var participants := int(options.get("participants", 25 if mode_id == "25_player_deathmatch" else 6))
	var content_db := _content_db()
	content_db.load_all()
	var room: MatchRoom = load("res://server/match/MatchRoom.gd").new()
	room.configure({"match_id": "friend_smoke_%s" % mode_id, "mode_id": mode_id, "participants": participants, "friend_team_mode": "together", "seed": 23}, content_db)
	room.add_session(ClientSession.make_human("friend_1", "hero_guardian", "Host"))
	room.add_session(ClientSession.make_human("friend_2", "hero_oracle", "Friend"))
	room.start_match()
	for _i in range(120):
		room.tick_fixed()
	var errors: Array[String] = []
	if room.get_human_count() != 2:
		errors.append("expected two simulated human clients")
	if mode_id == "3v3_team_arena" and room.get_bot_count() != 4:
		errors.append("3v3 friend smoke expected 4 bots")
	if mode_id == "25_player_deathmatch" and room.get_bot_count() != 23:
		errors.append("deathmatch friend smoke expected 23 bots")
	var snapshot := room.get_last_snapshot()
	if snapshot.entities.size() != participants:
		errors.append("snapshot participant count mismatch")
	if not errors.is_empty():
		var fail_payload := {"cmd": "friend-smoke", "mode": mode_id, "status": "fail", "errors": errors}
		_write_artifact(mode_id, fail_payload)
		print(JSON.stringify(fail_payload))
		return 6
	var payload := {"cmd": "friend-smoke", "mode": mode_id, "status": "pass", "humans": room.get_human_count(), "bots": room.get_bot_count(), "participants": snapshot.entities.size()}
	_write_artifact(mode_id, payload)
	print(JSON.stringify(payload))
	return 0

func _content_db() -> Object:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root.get_node("/root/ContentDB")

func _write_artifact(mode_id: String, payload: Dictionary) -> void:
	var dir := "res://qa_artifacts/logs"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var file := FileAccess.open("%s/friend_smoke_%s.json" % [dir, mode_id], FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))
