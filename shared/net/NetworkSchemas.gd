class_name NetworkSchemas
extends RefCounted

static func validate_envelope(envelope: NetworkEnvelope) -> Array[String]:
	var errors := envelope.validate_basic()
	match envelope.message_type:
		ProtocolConstants.PLAYER_INPUT:
			var frame := InputFrame.from_dict(envelope.payload)
			if not frame.is_valid():
				errors.append("player_input payload is invalid")
		ProtocolConstants.WORLD_SNAPSHOT:
			if not envelope.payload.has("server_tick"):
				errors.append("world_snapshot missing server_tick")
		ProtocolConstants.MATCH_FINISHED:
			if not envelope.payload.has("match_id"):
				errors.append("match_finished missing match_id")
	return errors
