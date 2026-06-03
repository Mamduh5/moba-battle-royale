class_name MatchClient
extends RefCounted

const STATE_DISCONNECTED := "disconnected"
const STATE_CONNECTING := "connecting"
const STATE_JOINED := "joined"
const STATE_FINISHED := "finished"

var _state := STATE_DISCONNECTED
var _room: MatchRoom = null
var _player_id := ""
var _token := ""
var _latest_snapshot: SnapshotFrame = null
var _latest_events: Array[Dictionary] = []
var _prediction := PredictionBuffer.new()
var _interpolator := SnapshotInterpolator.new()
var _reconciliation := ReconciliationClient.new()

func connect_to_match(_host: String, _port: int, token: String) -> bool:
	_token = token
	_state = STATE_CONNECTING
	return token != ""

func connect_local(room: MatchRoom, player_id: String, token: String) -> bool:
	_room = room
	_player_id = player_id
	_token = token
	_state = STATE_JOINED if room != null and token != "" else STATE_DISCONNECTED
	return _state == STATE_JOINED

func disconnect_from_match(_reason: String) -> void:
	_state = STATE_DISCONNECTED
	_room = null
	_latest_snapshot = null
	_latest_events.clear()
	_interpolator.clear()

func send_input(input: InputFrame) -> void:
	if _state != STATE_JOINED or _room == null:
		return
	_prediction.push_input(input)
	_room.receive_input(_player_id, input)

func poll_network() -> void:
	if _room == null or _state == STATE_DISCONNECTED:
		return
	_latest_snapshot = _room.get_last_snapshot()
	_latest_events = _room.get_last_events()
	if _latest_snapshot != null:
		_latest_snapshot.events = _latest_events.duplicate(true)
		_interpolator.push(_latest_snapshot)
		var last_input := int(_latest_snapshot.last_processed_input_by_player.get(_player_id, 0))
		_prediction.acknowledge(last_input)
	if _room.is_finished():
		_state = STATE_FINISHED

func get_connection_state() -> String:
	return _state

func get_latest_snapshot() -> SnapshotFrame:
	return _interpolator.latest()

func get_player_id() -> String:
	return _player_id
