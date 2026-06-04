class_name ProtocolCheckCommand
extends RefCounted

func run(_options: Dictionary = {}) -> int:
	var errors: Array[String] = []
	for message_type in ProtocolConstants.known_message_types():
		var env := NetworkEnvelope.new()
		env.message_type = message_type
		env.match_id = "check_match"
		env.player_id = "check_player"
		env.sequence = 1
		env.sent_at_ms = 1
		env.payload = _payload_for(message_type)
		var encoded := NetworkCodec.encode(env)
		if encoded.is_empty():
			errors.append("encode failed for %s" % message_type)
			continue
		var decoded := NetworkCodec.decode(encoded)
		if decoded.message_type != message_type:
			errors.append("roundtrip mismatch for %s" % message_type)
		errors.append_array(NetworkSchemas.validate_envelope(decoded))
	var input := InputFrame.new()
	input.player_id = "check_player"
	input.move_x = 4.0
	input.move_y = 2.0
	input.aim_x = 9.0
	input.aim_y = 0.0
	var normalized := input.normalized()
	if Vector2(normalized.move_x, normalized.move_y).length() > 1.001:
		errors.append("input movement was not clamped")
	var bad := NetworkEnvelope.new()
	bad.message_type = "unknown_type"
	bad.sequence = 1
	bad.sent_at_ms = 1
	if bad.validate_basic().is_empty():
		errors.append("unknown message type was not rejected")
	if not errors.is_empty():
		print(JSON.stringify({"cmd": "protocol-check", "status": "fail", "errors": errors}))
		return 5
	print(JSON.stringify({"cmd": "protocol-check", "status": "pass", "message_types": ProtocolConstants.known_message_types()}))
	return 0

func _payload_for(message_type: String) -> Dictionary:
	match message_type:
		ProtocolConstants.PLAYER_INPUT:
			var frame := InputFrame.new()
			frame.player_id = "check_player"
			return frame.to_dict()
		ProtocolConstants.WORLD_SNAPSHOT:
			var snapshot := SnapshotFrame.new()
			snapshot.match_id = "check_match"
			snapshot.server_tick = 10
			return snapshot.to_dict()
		ProtocolConstants.MATCH_FINISHED:
			return {"match_id": "check_match", "server_tick": 10, "player_results": {}}
		_:
			return {"ok": true}
