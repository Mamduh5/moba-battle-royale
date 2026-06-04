class_name BotSoakCommand
extends RefCounted

func run(options: Dictionary = {}) -> int:
	var mode_id := str(options.get("mode", "3v3_team_arena"))
	var matches := int(options.get("matches", 3))
	var participants := int(options.get("participants", 25 if mode_id == "25_player_deathmatch" else 6))
	var errors: Array[String] = []
	var total_ticks := 0
	var finished_count := 0
	var total_kills := 0
	_write_artifact(mode_id, {"cmd": "bot-soak", "mode": mode_id, "status": "started", "matches": matches, "participants": participants})
	for index in range(matches):
		var room := _make_room(mode_id, participants, 1)
		_write_artifact("%s_match_%d_stage" % [mode_id, index], {"stage": "configured", "mode": mode_id, "match_index": index})
		room.start_match()
		_write_artifact("%s_match_%d_stage" % [mode_id, index], {"stage": "started", "mode": mode_id, "match_index": index})
		_apply_soak_limits(room, mode_id)
		_write_artifact("%s_match_%d_stage" % [mode_id, index], {"stage": "limits_applied", "mode": mode_id, "match_index": index})
		var guard := 0
		while not room.is_finished() and guard < 9000:
			room.tick_fixed()
			guard += 1
			if guard % 200 == 0:
				_write_artifact("%s_match_%d_stage" % [mode_id, index], {"stage": "ticking", "mode": mode_id, "match_index": index, "guard": guard, "finished": room.is_finished()})
		_write_artifact("%s_match_%d" % [mode_id, index], {"cmd": "bot-soak-match", "mode": mode_id, "match_index": index, "guard": guard, "finished": room.is_finished()})
		if not room.is_finished():
			errors.append("match %d did not finish" % index)
		else:
			finished_count += 1
		total_ticks += guard
		total_kills += 0
		var loop_status := "fail" if not errors.is_empty() else ("pass" if index == matches - 1 else "running")
		var loop_payload := {"cmd": "bot-soak", "mode": mode_id, "status": loop_status, "matches": matches, "participants": participants, "finished": finished_count, "average_ticks": float(total_ticks) / float(max(1, index + 1)), "kills": total_kills, "errors": errors.duplicate()}
		_write_artifact(mode_id, loop_payload)
	if not errors.is_empty():
		var fail_payload := {"cmd": "bot-soak", "mode": mode_id, "status": "fail", "matches": matches, "participants": participants, "errors": errors}
		_write_artifact(mode_id, fail_payload)
		print(JSON.stringify(fail_payload))
		return 7
	var average_ticks := float(total_ticks) / float(max(1, matches))
	var payload := {"cmd": "bot-soak", "mode": mode_id, "status": "pass", "matches": matches, "participants": participants, "finished": finished_count, "average_ticks": average_ticks, "kills": total_kills, "errors": []}
	_write_artifact(mode_id, payload)
	print(JSON.stringify(payload))
	return 0

func _make_room(mode_id: String, participants: int, seed: int) -> MatchRoom:
	var content_db := _content_db()
	content_db.load_all()
	var room: MatchRoom = load("res://server/match/MatchRoom.gd").new()
	room.configure({"match_id": "soak_%s_%d" % [mode_id, seed], "mode_id": mode_id, "participants": participants, "seed": seed, "tick_rate": 30}, content_db)
	return room

func _content_db() -> Object:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root.get_node("/root/ContentDB")

func _apply_soak_limits(room: MatchRoom, mode_id: String) -> void:
	var state := room.get_world().get_state()
	state.rules["score_limit"] = 5 if mode_id == "25_player_deathmatch" else 6
	state.rules["duration_ticks"] = 30 if mode_id == "25_player_deathmatch" else min(int(state.rules.get("duration_ticks", 3600)), 2400)
	state.scoreboard["ticks_remaining"] = state.rules["duration_ticks"]

func _has_nan(snapshot: SnapshotFrame) -> bool:
	for entity in snapshot.entities:
		var pos: Dictionary = entity.get("position", {})
		if is_nan(float(pos.get("x", 0.0))) or is_nan(float(pos.get("y", 0.0))):
			return true
	return false

func _write_artifact(mode_id: String, payload: Dictionary) -> void:
	var dir := "res://qa_artifacts/logs"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var file := FileAccess.open("%s/bot_soak_%s.json" % [dir, mode_id], FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload))
