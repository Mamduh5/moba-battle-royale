class_name SnapshotEncoder
extends RefCounted

func encode_snapshot(snapshot: SnapshotFrame) -> PackedByteArray:
	var envelope := NetworkEnvelope.new()
	envelope.message_type = ProtocolConstants.WORLD_SNAPSHOT
	envelope.match_id = snapshot.match_id
	envelope.server_tick = snapshot.server_tick
	envelope.payload = snapshot.to_dict()
	envelope.sent_at_ms = int(Time.get_unix_time_from_system() * 1000.0)
	return NetworkCodec.encode(envelope)
