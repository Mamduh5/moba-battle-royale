extends Node

func get_version() -> String:
	return ProtocolConstants.VERSION

func encode(message_type: String, payload: Dictionary, metadata: Dictionary = {}) -> PackedByteArray:
	var envelope := NetworkEnvelope.new()
	envelope.protocol_version = ProtocolConstants.VERSION
	envelope.message_type = message_type
	envelope.match_id = str(metadata.get("match_id", ""))
	envelope.player_id = str(metadata.get("player_id", ""))
	envelope.sequence = int(metadata.get("sequence", 0))
	envelope.client_tick = int(metadata.get("client_tick", 0))
	envelope.server_tick = int(metadata.get("server_tick", 0))
	envelope.sent_at_ms = int(metadata.get("sent_at_ms", Time.get_unix_time_from_system() * 1000.0))
	envelope.payload = payload.duplicate(true)
	return NetworkCodec.encode(envelope)

func decode(bytes: PackedByteArray) -> NetworkEnvelope:
	return NetworkCodec.decode(bytes)
