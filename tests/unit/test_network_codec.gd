extends RefCounted

func run() -> Array[String]:
	var errors: Array[String] = []
	var env := NetworkEnvelope.new()
	env.message_type = ProtocolConstants.CLIENT_HELLO
	env.sequence = 1
	env.sent_at_ms = 1
	env.payload = {"ok": true}
	var decoded := NetworkCodec.decode(NetworkCodec.encode(env))
	if decoded.message_type != env.message_type:
		errors.append("codec round trip failed")
	return errors
