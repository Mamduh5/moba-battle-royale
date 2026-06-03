class_name LocalLoopbackTransport
extends ServerTransport

var _messages_by_player: Dictionary = {}
var _started := false

func start(_host: String, _port: int) -> bool:
	_started = true
	return true

func stop() -> void:
	_started = false
	_messages_by_player.clear()

func send_to_player(player_id: String, message_type: String, payload: Dictionary) -> void:
	if not _messages_by_player.has(player_id):
		_messages_by_player[player_id] = []
	var messages: Array = _messages_by_player[player_id]
	messages.append({"message_type": message_type, "payload": payload})
	_messages_by_player[player_id] = messages

func broadcast(_match_id: String, message_type: String, payload: Dictionary) -> void:
	for player_id in _messages_by_player.keys():
		send_to_player(str(player_id), message_type, payload)

func drain_for_player(player_id: String) -> Array:
	var messages: Array = _messages_by_player.get(player_id, []).duplicate(true)
	_messages_by_player[player_id] = []
	return messages
