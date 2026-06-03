class_name RunTestsCommand
extends RefCounted

func run(_args: Dictionary, content_db: Object) -> int:
	var failures: Array[String] = []
	_test_content(content_db, failures)
	_test_input_frame(failures)
	_test_network_codec(failures)
	_test_match_room(content_db, GameConstants.MODE_TEAM_ARENA, failures)
	_test_match_room(content_db, GameConstants.MODE_DEATHMATCH, failures)
	if not failures.is_empty():
		for failure in failures:
			printerr("test_failure: %s" % failure)
		return ProtocolConstants.EXIT_TEST_FAILURE
	print("run-tests: ok unit=3 integration=2 protocol=1")
	return ProtocolConstants.EXIT_SUCCESS

func _test_content(content_db: Object, failures: Array[String]) -> void:
	content_db.load_all()
	var errors: Array[String] = content_db.validate_all()
	if not errors.is_empty():
		failures.append("content validation failed: %s" % [errors])

func _test_input_frame(failures: Array[String]) -> void:
	var frame := InputFrame.new()
	frame.player_id = "p"
	frame.move_x = 2.0
	frame.move_y = 2.0
	var normalized := frame.normalized()
	if Vector2(normalized.move_x, normalized.move_y).length() > 1.001:
		failures.append("InputFrame diagonal movement not normalized")

func _test_network_codec(failures: Array[String]) -> void:
	var envelope := NetworkEnvelope.new()
	envelope.message_type = ProtocolConstants.MSG_CLIENT_HELLO
	envelope.sequence = 1
	envelope.sent_at_ms = 1
	envelope.payload = {"client_build": GameConstants.BUILD_VERSION, "platform": "desktop"}
	failures.append_array(NetworkCodec.round_trip(envelope))

func _test_match_room(content_db: Object, mode_id: String, failures: Array[String]) -> void:
	var room := MatchRoom.new()
	room.configure({"mode_id": mode_id, "match_id": "test_%s" % mode_id, "seed": 7001}, content_db)
	room.add_session(ClientSession.human("player_test", GameConstants.DEFAULT_HERO))
	room.start_match()
	var mode: ModeDef = content_db.get_mode(mode_id)
	var ticks := 0
	var max_ticks := mode.duration_sec * 30 + 600
	while not room.is_finished() and ticks < max_ticks:
		room.tick(1.0 / 30.0)
		ticks += 1
	var result := room.build_result()
	if not room.is_finished():
		failures.append("MatchRoom %s did not finish" % mode_id)
	var rankings: Array = result.get("rankings", [])
	if rankings.size() != mode.max_participants:
		failures.append("MatchRoom %s result missing participants" % mode_id)
