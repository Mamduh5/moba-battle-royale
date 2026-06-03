class_name TcpServerTransport
extends ServerTransport

const MAX_READ_BYTES := 65536

var _server := TCPServer.new()
var _peers: Dictionary = {}
var _buffers: Dictionary = {}
var _next_peer_id := 1
var _started := false
var _host := "127.0.0.1"
var _port := 0
var _inbox: Array[Dictionary] = []
var _network_log: Array[Dictionary] = []

func start(host: String, port: int) -> bool:
	_host = host
	_port = port
	var error := _server.listen(port, host)
	_started = error == OK
	_log("transport_start", {"host": host, "port": port, "ok": _started, "error": error})
	return _started

func stop() -> void:
	for peer_id in _peers.keys():
		var peer: StreamPeerTCP = _peers[peer_id]
		peer.disconnect_from_host()
	_peers.clear()
	_buffers.clear()
	_inbox.clear()
	if _started:
		_server.stop()
	_started = false
	_log("transport_stop", {"host": _host, "port": _port})

func poll_network() -> void:
	if not _started:
		return
	while _server.is_connection_available():
		var peer := _server.take_connection()
		if peer != null:
			var peer_id := "peer_%03d" % _next_peer_id
			_next_peer_id += 1
			_peers[peer_id] = peer
			_buffers[peer_id] = ""
			_log("peer_connected", {"peer_id": peer_id})
	for peer_id in _peers.keys():
		var peer: StreamPeerTCP = _peers[peer_id]
		peer.poll()
		var status := peer.get_status()
		if status == StreamPeerTCP.STATUS_ERROR or status == StreamPeerTCP.STATUS_NONE:
			_log("peer_disconnected", {"peer_id": peer_id, "status": status})
			_peers.erase(peer_id)
			_buffers.erase(peer_id)
			continue
		var available := peer.get_available_bytes()
		if available <= 0:
			continue
		var read_size: int = min(available, MAX_READ_BYTES)
		var chunk: Array = peer.get_data(read_size)
		if int(chunk[0]) != OK:
			_log("peer_read_error", {"peer_id": peer_id, "error": int(chunk[0])})
			continue
		_buffers[peer_id] = str(_buffers.get(peer_id, "")) + (chunk[1] as PackedByteArray).get_string_from_utf8()
		_drain_peer_lines(str(peer_id))

func send_to_peer(peer_id: String, message_type: String, payload: Dictionary) -> void:
	if not _peers.has(peer_id):
		return
	var envelope := {
		"message_type": message_type,
		"payload": payload,
	}
	var bytes := (JSON.stringify(envelope) + "\n").to_utf8_buffer()
	var peer: StreamPeerTCP = _peers[peer_id]
	var error := peer.put_data(bytes)
	_log("send", {"peer_id": peer_id, "message_type": message_type, "bytes": bytes.size(), "error": error})

func send_to_player(player_id: String, message_type: String, payload: Dictionary) -> void:
	for peer_id in _peers.keys():
		send_to_peer(str(peer_id), message_type, payload)

func broadcast(match_id: String, message_type: String, payload: Dictionary) -> void:
	for peer_id in _peers.keys():
		var enriched := payload.duplicate(true)
		enriched["match_id"] = match_id
		send_to_peer(str(peer_id), message_type, enriched)

func drain_messages() -> Array[Dictionary]:
	var messages := _inbox.duplicate(true)
	_inbox.clear()
	return messages

func get_network_log() -> Array[Dictionary]:
	return _network_log.duplicate(true)

func _drain_peer_lines(peer_id: String) -> void:
	var buffer := str(_buffers.get(peer_id, ""))
	while buffer.find("\n") >= 0:
		var index := buffer.find("\n")
		var line := buffer.substr(0, index).strip_edges()
		buffer = buffer.substr(index + 1)
		if line == "":
			continue
		var parsed = JSON.parse_string(line)
		if typeof(parsed) == TYPE_DICTIONARY:
			var message: Dictionary = parsed
			message["peer_id"] = peer_id
			_inbox.append(message)
			_log("receive", {"peer_id": peer_id, "message_type": str(message.get("message_type", ""))})
		else:
			_log("receive_invalid_json", {"peer_id": peer_id})
	_buffers[peer_id] = buffer

func _log(event: String, fields: Dictionary = {}) -> void:
	var line := fields.duplicate(true)
	line["event"] = event
	line["time_ms"] = Time.get_ticks_msec()
	_network_log.append(line)
