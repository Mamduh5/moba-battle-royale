class_name MatchServer
extends RefCounted

var _transport: ServerTransport = LocalLoopbackTransport.new()
var _rooms: Dictionary = {}
var _host := "127.0.0.1"
var _port := 24560

func start(host: String, port: int) -> bool:
	_host = host
	_port = port
	return _transport.start(host, port)

func stop() -> void:
	_transport.stop()
	_rooms.clear()

func poll_network() -> void:
	_transport.poll_network()

func send_to_player(player_id: String, message_type: String, payload: Dictionary) -> void:
	_transport.send_to_player(player_id, message_type, payload)

func broadcast(match_id: String, message_type: String, payload: Dictionary) -> void:
	_transport.broadcast(match_id, message_type, payload)

func create_room(match_config: Dictionary, content_db: Object) -> MatchRoom:
	var room := MatchRoom.new()
	room.configure(match_config, content_db)
	_rooms[room.match_id] = room
	return room

func get_room(match_id: String) -> MatchRoom:
	return _rooms.get(match_id, null)
