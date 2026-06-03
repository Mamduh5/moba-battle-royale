class_name NetworkSchemas
extends RefCounted

static func validate_payload(message_type: String, payload: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	match message_type:
		ProtocolConstants.MSG_CLIENT_HELLO:
			_require(payload, "client_build", errors)
			_require(payload, "platform", errors)
		ProtocolConstants.MSG_JOIN_MATCH:
			_require(payload, "match_token", errors)
			_require(payload, "selected_hero_id", errors)
		ProtocolConstants.MSG_PLAYER_INPUT:
			var frame := InputFrame.from_dict(payload)
			if not frame.is_valid():
				errors.append("Invalid player_input frame")
		ProtocolConstants.MSG_WORLD_SNAPSHOT:
			_require(payload, "snapshot_id", errors)
			_require(payload, "server_tick", errors)
			_require(payload, "entities", errors)
		ProtocolConstants.MSG_MATCH_FINISHED:
			_require(payload, "match_id", errors)
			_require(payload, "reason", errors)
		_:
			if not ProtocolConstants.known_message_types().has(message_type):
				errors.append("Unknown message_type: %s" % message_type)
	return errors

static func _require(payload: Dictionary, key: String, errors: Array[String]) -> void:
	if not payload.has(key):
		errors.append("Missing payload field: %s" % key)
