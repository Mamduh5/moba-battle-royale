class_name MatchClient
extends RefCounted

var _state := "disconnected"
var _token := ""
var _sent_inputs: Array[Dictionary] = []
var _received_snapshots: Array[Dictionary] = []

func connect_to_match(host: String, port: int, token: String) -> bool:
	_token = token
	_state = "connected:%s:%d" % [host, port]
	return true

func disconnect_from_match(reason: String) -> void:
	_state = "disconnected:%s" % reason

func send_input(input: InputFrame) -> void:
	_sent_inputs.append(input.to_dict())

func receive_snapshot(snapshot: SnapshotFrame) -> void:
	_received_snapshots.append(snapshot.to_dict())

func poll_network() -> void:
	pass

func get_connection_state() -> String:
	return _state
