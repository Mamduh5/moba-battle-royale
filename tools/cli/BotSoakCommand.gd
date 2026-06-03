class_name BotSoakCommand
extends RefCounted

func run(args: Dictionary, content_db: Object) -> int:
	var mode_id := str(args.get("mode", GameConstants.MODE_TEAM_ARENA))
	var matches := int(args.get("matches", 3))
	var requested_participants := int(args.get("participants", 0))
	content_db.load_all()
	var errors: Array[String] = content_db.validate_all()
	if not errors.is_empty():
		for error in errors:
			printerr("bot_soak_content_error: %s" % error)
		return ProtocolConstants.EXIT_CONTENT_VALIDATION_FAILURE
	var mode: ModeDef = content_db.get_mode(mode_id)
	if mode == null:
		printerr("bot-soak missing mode: %s" % mode_id)
		return ProtocolConstants.EXIT_INVALID_ARGUMENTS
	var failures: Array[String] = []
	var total_ticks := 0
	var total_kills := 0
	var total_deaths := 0
	for i in range(matches):
		var room := MatchRoom.new()
		room.configure({"mode_id": mode_id, "match_id": "soak_%s_%02d" % [mode_id, i], "seed": 9000 + i}, content_db)
		room.start_match()
		var max_ticks: int = max(mode.duration_sec * 30 + 600, 1200)
		var ticks := 0
		while not room.is_finished() and ticks < max_ticks:
			room.tick(1.0 / 30.0)
			ticks += 1
		var result := room.build_result()
		total_ticks += ticks
		var rankings: Array = result.get("rankings", [])
		for entry in rankings:
			total_kills += int(entry.get("kills", 0))
			total_deaths += int(entry.get("deaths", 0))
		if not room.is_finished():
			failures.append("match %d did not finish within %d ticks" % [i, max_ticks])
		if requested_participants > 0 and rankings.size() != requested_participants:
			failures.append("match %d participants expected %d got %d" % [i, requested_participants, rankings.size()])
		elif requested_participants == 0 and rankings.size() != mode.max_participants:
			failures.append("match %d participants expected %d got %d" % [i, mode.max_participants, rankings.size()])
		_assert_positions(room, failures, i)
	if not failures.is_empty():
		for failure in failures:
			printerr("bot_soak_failure: %s" % failure)
		return ProtocolConstants.EXIT_BOT_SOAK_FAILURE
	var avg_ticks := float(total_ticks) / float(max(matches, 1))
	print("bot-soak: ok mode=%s matches=%d participants=%d avg_ticks=%.1f kills=%d deaths=%d errors=0" % [
		mode_id,
		matches,
		requested_participants if requested_participants > 0 else mode.max_participants,
		avg_ticks,
		total_kills,
		total_deaths,
	])
	return ProtocolConstants.EXIT_SUCCESS

func _assert_positions(room: MatchRoom, failures: Array[String], match_index: int) -> void:
	var state := room.get_world().get_state()
	for entity_id in state.query_entities({"kind": "hero"}):
		var entity := state.get_entity(entity_id)
		var position: Vector2 = entity.get("position", Vector2.ZERO)
		if not is_finite(position.x) or not is_finite(position.y):
			failures.append("match %d entity %d has invalid position" % [match_index, entity_id])
