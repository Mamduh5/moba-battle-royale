class_name MatchScene
extends Control

signal match_finished(result: Dictionary)
signal menu_requested

var mode_id := "3v3_team_arena"
var local_player_id := GameConstants.LOCAL_PLAYER_ID
var selected_hero_id := "hero_guardian"
var room_code := "LOCAL-ARENA"

var _room: MatchRoom = null
var _input_sampler := InputSampler.new()
var _input_sequence := 0
var _world_view := GameWorldView.new()
var _hud := HUD.new()
var _pause_menu := PauseMenu.new()
var _match_client := MatchClient.new()
var _finish_reported := false

func _ready() -> void:
	theme = ArenaTheme.create_theme()
	add_child(_world_view)
	add_child(_hud)
	add_child(_pause_menu)
	_pause_menu.resume_requested.connect(_resume)
	_pause_menu.menu_requested.connect(menu_requested.emit)
	_world_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_menu.set_anchors_preset(Control.PRESET_FULL_RECT)

func configure_match(next_mode_id: String, hero_id: String = "hero_guardian", code: String = "LOCAL-ARENA") -> void:
	mode_id = next_mode_id
	selected_hero_id = hero_id
	room_code = code
	local_player_id = GameConstants.LOCAL_PLAYER_ID
	var backend := LocalNakamaAdapter.new()
	var token := backend.issue_match_token({"match_id": room_code, "player_id": local_player_id, "team_id": 1})
	_match_client.connect_to_match(str(token.get("match_server_host", "127.0.0.1")), int(token.get("match_server_port", 24560)), str(token.get("match_token", "")))
	_room = MatchRoom.new()
	_room.configure({"match_id": room_code, "mode_id": mode_id, "participants": 25 if mode_id == "25_player_deathmatch" else 6, "friend_team_mode": "together", "seed": 42}, ContentDB)
	_room.add_session(ClientSession.make_human(local_player_id, selected_hero_id, "You"))
	_room.start_match()
	_apply_snapshot(_room.get_last_snapshot())

func _process(delta: float) -> void:
	if _room == null or _pause_menu.visible:
		return
	_input_sequence += 1
	var input := _input_sampler.sample(local_player_id, _room.get_world().get_tick(), _input_sequence)
	_match_client.send_input(input)
	_room.receive_input(local_player_id, input)
	_room.tick(delta)
	_apply_snapshot(_room.get_last_snapshot())
	if _room.is_finished() and not _finish_reported:
		_finish_reported = true
		match_finished.emit(_room.build_result())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		_pause_menu.visible = not _pause_menu.visible
		_pause_menu.queue_redraw()

func _apply_snapshot(snapshot: SnapshotFrame) -> void:
	if snapshot == null or _room == null:
		return
	_match_client.receive_snapshot(snapshot)
	_world_view.set_world(snapshot, _room.get_world().get_map(), local_player_id)
	_hud.set_snapshot(snapshot, local_player_id, ContentDB)

func _resume() -> void:
	_pause_menu.visible = false
	_pause_menu.queue_redraw()
