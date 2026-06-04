class_name MatchServer
extends RefCounted

var _transport := ServerTransport.new()
var _rooms: Dictionary = {}

func start(host: String, port: int) -> bool:
	return _transport.start(host, port)

func stop() -> void:
	_transport.stop()

func poll_network() -> void:
	_transport.poll_network()

func add_room(room: MatchRoom) -> void:
	_rooms[room.match_id] = room

func send_to_player(player_id: String, message_type: String, payload: Dictionary) -> void:
	_transport.send_to_player(player_id, message_type, payload)

func broadcast(match_id: String, message_type: String, payload: Dictionary) -> void:
	_transport.broadcast(match_id, message_type, payload)

func get_debug_outbox() -> Array[Dictionary]:
	return _transport.drain_outbox()
