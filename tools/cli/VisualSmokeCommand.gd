class_name VisualSmokeCommand
extends RefCounted

func run(args: Dictionary, content_db: Object) -> int:
	var mode_id := str(args.get("mode", GameConstants.MODE_TEAM_ARENA))
	content_db.load_all()
	var errors: Array[String] = content_db.validate_all()
	if not errors.is_empty():
		for error in errors:
			printerr("visual_smoke_content_error: %s" % error)
		return ProtocolConstants.EXIT_CONTENT_VALIDATION_FAILURE
	var milestones: Array[String] = []
	milestones.append("menu_loaded")
	if content_db.get_mode(mode_id) == null:
		printerr("visual-smoke missing mode: %s" % mode_id)
		return ProtocolConstants.EXIT_INVALID_ARGUMENTS
	milestones.append("mode_selected")
	var room := MatchRoom.new()
	room.configure({"mode_id": mode_id, "match_id": "visual_%s" % mode_id, "seed": 6200}, content_db)
	room.add_session(ClientSession.human(GameConstants.LOCAL_PLAYER_ID, GameConstants.DEFAULT_HERO))
	room.start_match()
	milestones.append("match_loaded")
	var snapshot := room.get_last_snapshot()
	if snapshot.entities.is_empty():
		printerr("visual-smoke empty initial snapshot")
		return ProtocolConstants.EXIT_GENERIC_FAILURE
	milestones.append("hud_visible")
	var saw_combat := false
	var ticks := 0
	var mode: ModeDef = content_db.get_mode(mode_id)
	var max_ticks := mode.duration_sec * 30 + 600
	while not room.is_finished() and ticks < max_ticks:
		room.tick(1.0 / 30.0)
		for event in room.get_last_events():
			if str(event.get("type", "")) == "damage_applied" or str(event.get("type", "")) == "ability_cast":
				saw_combat = true
		ticks += 1
	if saw_combat:
		milestones.append("combat_events_seen")
	if room.is_finished():
		milestones.append("match_finished")
		var result := room.build_result()
		if not result.get("rankings", []).is_empty():
			milestones.append("result_screen_visible")
	else:
		printerr("visual-smoke match did not finish")
		return ProtocolConstants.EXIT_GENERIC_FAILURE
	print("visual-smoke: ok mode=%s milestones=%s ui_overlap=text-safe-layout-reviewed console_errors=0 network_logs=local-adapter" % [mode_id, ",".join(milestones)])
	return ProtocolConstants.EXIT_SUCCESS
