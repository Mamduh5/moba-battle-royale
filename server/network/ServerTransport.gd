class_name ServerTransport
extends RefCounted

var _started := false
var _host := "127.0.0.1"
var _port := 24560
var _outbox: Array[Dictionary] = []

func start(host: String, port: int) -> bool:
	_host = host
	_port = port
	_started = true
	_outbox.clear()
	return true

func stop() -> void:
	_started = false

func is_started() -> bool:
	return _started

func poll_network() -> void:
	pass

func send_to_player(player_id: String, message_type: String, payload: Dictionary) -> void:
	_outbox.append({"player_id": player_id, "message_type": message_type, "payload": payload.duplicate(true)})

func broadcast(match_id: String, message_type: String, payload: Dictionary) -> void:
	_outbox.append({"match_id": match_id, "message_type": message_type, "payload": payload.duplicate(true)})

func drain_outbox() -> Array[Dictionary]:
	var out := _outbox.duplicate(true)
	_outbox.clear()
	return out
