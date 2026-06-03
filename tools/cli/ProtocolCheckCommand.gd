class_name ProtocolCheckCommand
extends RefCounted

func run(_args: Dictionary) -> int:
	var errors: Array[String] = []
	_check_round_trip(ProtocolConstants.MSG_CLIENT_HELLO, {"client_build": GameConstants.BUILD_VERSION, "platform": "desktop"}, errors)
	_check_round_trip(ProtocolConstants.MSG_JOIN_MATCH, {"match_token": "dev", "selected_hero_id": GameConstants.DEFAULT_HERO}, errors)
	var frame := InputFrame.new()
	frame.player_id = "player_01"
	frame.input_sequence = 1
	frame.client_tick = 2
	frame.move_x = 2.0
	frame.move_y = 2.0
	var normalized := frame.normalized()
	if normalized.move_x > 1.0 or normalized.move_y > 1.0 or normalized.to_dict().get("move", {}).is_empty():
		errors.append("InputFrame did not clamp movement.")
	_check_round_trip(ProtocolConstants.MSG_PLAYER_INPUT, normalized.to_dict(), errors)
	var snapshot := SnapshotFrame.new()
	snapshot.match_id = "match_protocol"
	snapshot.server_tick = 10
	snapshot.snapshot_id = 1
	snapshot.entities = []
	snapshot.scoreboard = {}
	_check_round_trip(ProtocolConstants.MSG_WORLD_SNAPSHOT, snapshot.to_dict(), errors)
	var unknown := NetworkEnvelope.new()
	unknown.message_type = "unknown_message"
	unknown.sent_at_ms = 1
	if unknown.validate_basic().is_empty():
		errors.append("Unknown message type was not rejected.")
	if not errors.is_empty():
		for error in errors:
			printerr("protocol_error: %s" % error)
		return ProtocolConstants.EXIT_PROTOCOL_FAILURE
	print("protocol-check: ok messages=%d" % ProtocolConstants.known_message_types().size())
	return ProtocolConstants.EXIT_SUCCESS

func _check_round_trip(message_type: String, payload: Dictionary, errors: Array[String]) -> void:
	var envelope := NetworkEnvelope.new()
	envelope.protocol_version = ProtocolConstants.VERSION
	envelope.message_type = message_type
	envelope.match_id = "match_protocol"
	envelope.player_id = "player_01"
	envelope.sequence = 1
	envelope.client_tick = 1
	envelope.server_tick = 1
	envelope.sent_at_ms = 1
	envelope.payload = payload
	errors.append_array(NetworkCodec.round_trip(envelope))
	errors.append_array(NetworkSchemas.validate_payload(message_type, payload))
