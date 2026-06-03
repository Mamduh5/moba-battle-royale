class_name NetworkEnvelope
extends RefCounted

var protocol_version := ProtocolConstants.VERSION
var message_type := ""
var match_id := ""
var player_id := ""
var sequence := 0
var client_tick := 0
var server_tick := 0
var sent_at_ms := 0
var payload: Dictionary = {}

func to_dict() -> Dictionary:
	return {
		"protocol_version": protocol_version,
		"message_type": message_type,
		"match_id": match_id,
		"player_id": player_id,
		"sequence": sequence,
		"client_tick": client_tick,
		"server_tick": server_tick,
		"sent_at_ms": sent_at_ms,
		"payload": payload,
	}

static func from_dict(data: Dictionary) -> NetworkEnvelope:
	var env := NetworkEnvelope.new()
	env.protocol_version = str(data.get("protocol_version", ""))
	env.message_type = str(data.get("message_type", ""))
	env.match_id = str(data.get("match_id", ""))
	env.player_id = str(data.get("player_id", ""))
	env.sequence = int(data.get("sequence", 0))
	env.client_tick = int(data.get("client_tick", 0))
	env.server_tick = int(data.get("server_tick", 0))
	env.sent_at_ms = int(data.get("sent_at_ms", 0))
	env.payload = data.get("payload", {}).duplicate(true)
	return env

func validate_basic() -> Array[String]:
	var errors: Array[String] = []
	if protocol_version != ProtocolConstants.VERSION:
		errors.append("Unsupported protocol_version: %s" % protocol_version)
	if not ProtocolConstants.known_message_types().has(message_type):
		errors.append("Unknown message_type: %s" % message_type)
	if sequence < 0:
		errors.append("sequence must be non-negative")
	if client_tick < 0 or server_tick < 0:
		errors.append("ticks must be non-negative")
	if sent_at_ms < 0:
		errors.append("sent_at_ms must be non-negative")
	if typeof(payload) != TYPE_DICTIONARY:
		errors.append("payload must be a dictionary")
	return errors
