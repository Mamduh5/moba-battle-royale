class_name TcpFriendClient
extends RefCounted

const MAX_READ_BYTES := 65536

var player_id := ""
var _peer := StreamPeerTCP.new()
var _buffer := ""
var _inbox: Array[Dictionary] = []
var _network_log: Array[Dictionary] = []

func connect_to_host(host: String, port: int, id: String) -> bool:
	player_id = id
	var error := _peer.connect_to_host(host, port)
	_log("connect_start", {"host": host, "port": port, "player_id": player_id, "error": error})
	return error == OK

func poll_network() -> void:
	_peer.poll()
	var available := _peer.get_available_bytes()
	if available <= 0:
		return
	var chunk := _peer.get_data(min(available, MAX_READ_BYTES))
	if int(chunk[0]) != OK:
		_log("read_error", {"error": int(chunk[0])})
		return
	_buffer += (chunk[1] as PackedByteArray).get_string_from_utf8()
	_drain_lines()

func send(message_type: String, payload: Dictionary) -> void:
	var envelope := {
		"message_type": message_type,
		"payload": payload,
	}
	var bytes := (JSON.stringify(envelope) + "\n").to_utf8_buffer()
	var error := _peer.put_data(bytes)
	_log("send", {"message_type": message_type, "bytes": bytes.size(), "error": error})

func send_input(frame: InputFrame) -> void:
	send(ProtocolConstants.MSG_PLAYER_INPUT, frame.to_dict())

func drain_messages() -> Array[Dictionary]:
	var messages := _inbox.duplicate(true)
	_inbox.clear()
	return messages

func close_connection() -> void:
	_peer.disconnect_from_host()
	_log("disconnect", {"player_id": player_id})

func get_network_log() -> Array[Dictionary]:
	return _network_log.duplicate(true)

func _drain_lines() -> void:
	while _buffer.find("\n") >= 0:
		var index := _buffer.find("\n")
		var line := _buffer.substr(0, index).strip_edges()
		_buffer = _buffer.substr(index + 1)
		if line == "":
			continue
		var parsed = JSON.parse_string(line)
		if typeof(parsed) == TYPE_DICTIONARY:
			var message: Dictionary = parsed
			_inbox.append(message)
			_log("receive", {"message_type": str(message.get("message_type", ""))})
		else:
			_log("receive_invalid_json")

func _log(event: String, fields: Dictionary = {}) -> void:
	var line := fields.duplicate(true)
	line["event"] = event
	line["time_ms"] = Time.get_ticks_msec()
	line["player_id"] = player_id
	_network_log.append(line)
