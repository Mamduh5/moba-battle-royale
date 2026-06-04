class_name NetworkCodec
extends RefCounted

static func encode(envelope: NetworkEnvelope) -> PackedByteArray:
	var errors := envelope.validate_basic()
	if not errors.is_empty():
		push_error("Invalid network envelope: %s" % [errors])
		return PackedByteArray()
	return JSON.stringify(envelope.to_dict()).to_utf8_buffer()

static func decode(bytes: PackedByteArray) -> NetworkEnvelope:
	var text := bytes.get_string_from_utf8()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		var bad := NetworkEnvelope.new()
		bad.message_type = "invalid"
		bad.payload = {"error": "invalid_json"}
		return bad
	return NetworkEnvelope.from_dict(parsed)
