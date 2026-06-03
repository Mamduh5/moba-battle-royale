class_name ClientApp
extends Control

var _content_ready := false
var _selected_mode := GameConstants.MODE_TEAM_ARENA
var _selected_hero := GameConstants.DEFAULT_HERO
var _local_player_id := GameConstants.LOCAL_PLAYER_ID
var _room_code := ""
var _match_room: MatchRoom = null
var _match_client := MatchClient.new()
var _match_scene: MatchScene = null
var _hud: ArenaHUD = null
var _ui_layer: CanvasLayer = null
var _input_sampler := InputSampler.new()
var _backend := LocalNakamaAdapter.new()
var _sequence := 0
var _client_tick := 0
var _paused := false
var _screen_root: Control
var _pause_overlay: PanelContainer
var _last_result: Dictionary = {}

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_screen_root = Control.new()
	_screen_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_screen_root)
	_content_ready = ContentDB.load_all() and ContentDB.validate_all().is_empty()
	DebugBus.info("client", "boot", {"content_ready": _content_ready})
	_show_main_menu()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_match") and _match_room != null and not _match_room.is_finished():
		_set_paused(not _paused)
	if _match_room == null or _paused:
		return
	_client_tick += 1
	_sequence += 1
	_input_sampler.set_screen_origin(_match_scene.get_local_screen_origin() if _match_scene != null else get_viewport_rect().size * 0.5)
	var frame := _input_sampler.sample(_local_player_id, _client_tick, _sequence)
	_match_client.send_input(frame)
	_match_room.tick(delta)
	_match_client.poll_network()
	var snapshot := _match_client.get_latest_snapshot()
	if snapshot != null:
		_match_scene.apply_snapshot(snapshot)
		_hud.set_connection_state(_match_client.get_connection_state())
		_hud.set_snapshot(snapshot)
	if _match_room.is_finished():
		_last_result = _match_room.build_result()
		_show_result_screen(_last_result)

func _show_main_menu() -> void:
	_clear_screen()
	_match_room = null
	_match_client.disconnect_from_match("menu")
	var menu := MainMenuScreen.new()
	menu.quick_start_pressed.connect(func() -> void:
		_selected_mode = GameConstants.MODE_TEAM_ARENA
		_start_local_match(false)
	)
	menu.mode_select_pressed.connect(_show_mode_select)
	_screen_root.add_child(menu)

func _show_mode_select() -> void:
	_clear_screen()
	var screen := ModeSelectScreen.new()
	screen.setup(ContentDB, _selected_mode, _selected_hero)
	screen.start_with_bots.connect(func(mode_id: String, hero_id: String) -> void:
		_selected_mode = mode_id
		_selected_hero = hero_id
		_start_local_match(false)
	)
	screen.host_match.connect(func(room_code: String) -> void:
		_room_code = room_code
	)
	screen.join_match.connect(func(mode_id: String, hero_id: String, room_code: String) -> void:
		_selected_mode = mode_id
		_selected_hero = hero_id
		_room_code = room_code
		_start_local_match(true)
	)
	screen.back_pressed.connect(_show_main_menu)
	_screen_root.add_child(screen)

func _start_local_match(simulate_friend: bool) -> void:
	if not _content_ready:
		_show_error("Content validation failed. Check command output.")
		return
	_clear_screen()
	var loading_bg := ArenaBackdrop.new()
	loading_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_screen_root.add_child(loading_bg)
	var loading_panel := PanelContainer.new()
	loading_panel.anchor_left = 0.08
	loading_panel.anchor_top = 0.10
	loading_panel.anchor_right = 0.44
	loading_panel.anchor_bottom = 0.34
	ArenaStyle.style_panel_container(loading_panel, Color(0.045, 0.075, 0.085, 0.94), Color(1.000, 0.765, 0.275, 0.35))
	_screen_root.add_child(loading_panel)
	var loading_box := VBoxContainer.new()
	loading_box.add_theme_constant_override("separation", 10)
	loading_panel.add_child(loading_box)
	var loading := Label.new()
	loading.text = "Loading Match"
	ArenaStyle.style_label(loading, 34)
	loading_box.add_child(loading)
	var loading_sub := Label.new()
	loading_sub.text = "Filling empty slots with server-owned bots"
	ArenaStyle.style_label(loading_sub, 17, ArenaStyle.TEXT_MUTED)
	loading_box.add_child(loading_sub)
	var mode: ModeDef = ContentDB.get_mode(_selected_mode)
	var map: MapDef = ContentDB.get_map(mode.map_id)
	_match_room = MatchRoom.new()
	var match_id := "local_%d" % Time.get_ticks_msec()
	var room_code := _room_code if _room_code != "" else "LOCAL"
	_match_room.configure({"mode_id": _selected_mode, "match_id": match_id, "room_code": room_code, "backend": _backend}, ContentDB)
	_match_room.add_session(ClientSession.human(_local_player_id, _selected_hero))
	if simulate_friend:
		var friend_hero := "hero_shade" if _selected_hero != "hero_shade" else "hero_arcanist"
		_match_room.add_session(ClientSession.human("player_friend", friend_hero))
	_match_room.start_match()
	var token := _backend.issue_match_token(match_id, "local_user", _local_player_id, GameConstants.TEAM_A, _selected_hero, GameConfig.get_match_server_host(), GameConfig.get_match_server_port())
	_match_client.connect_local(_match_room, _local_player_id, str(token.get("match_token", "")))
	_input_sampler.set_hero_ability_slots(ContentDB.get_hero(_selected_hero).ability_slots)
	_clear_screen()
	_match_scene = load("res://scenes/client/MatchScene.tscn").instantiate()
	_match_scene.setup(map, _local_player_id)
	_screen_root.add_child(_match_scene)
	_ui_layer = CanvasLayer.new()
	_ui_layer.name = "MatchUiLayer"
	_screen_root.add_child(_ui_layer)
	_hud = load("res://scenes/ui/HUD.tscn").instantiate()
	_hud.setup(_local_player_id, _selected_mode)
	_ui_layer.add_child(_hud)
	_build_pause_overlay(_ui_layer)
	DebugBus.info("client", "match_started", {"match_id": match_id, "mode_id": _selected_mode, "room_code": room_code})

func _build_pause_overlay(parent: Node = null) -> void:
	_pause_overlay = PanelContainer.new()
	_pause_overlay.visible = false
	_pause_overlay.anchor_left = 0.36
	_pause_overlay.anchor_top = 0.25
	_pause_overlay.anchor_right = 0.64
	_pause_overlay.anchor_bottom = 0.62
	ArenaStyle.style_panel_container(_pause_overlay, Color(0.035, 0.052, 0.060, 0.96), Color(1.000, 0.765, 0.275, 0.50))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	_pause_overlay.add_child(box)
	var title := Label.new()
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ArenaStyle.style_label(title, 32)
	box.add_child(title)
	var resume := Button.new()
	resume.text = "Resume"
	ArenaStyle.style_button(resume, "primary", Vector2(220, 46))
	resume.pressed.connect(func() -> void: _set_paused(false))
	box.add_child(resume)
	var menu := Button.new()
	menu.text = "Return To Menu"
	ArenaStyle.style_button(menu, "secondary", Vector2(220, 46))
	menu.pressed.connect(_show_main_menu)
	box.add_child(menu)
	if parent == null:
		_screen_root.add_child(_pause_overlay)
	else:
		parent.add_child(_pause_overlay)

func _set_paused(value: bool) -> void:
	_paused = value
	if _pause_overlay != null:
		_pause_overlay.visible = value

func _show_result_screen(result: Dictionary) -> void:
	var local_team := GameConstants.TEAM_A
	if _match_room != null:
		var session := _match_room.get_session(_local_player_id)
		if session != null:
			local_team = session.team_id
	_match_room = null
	_clear_screen()
	var screen := ResultScreen.new()
	screen.setup(result, _selected_mode, _local_player_id, local_team)
	screen.restart_pressed.connect(func() -> void: _start_local_match(false))
	screen.menu_pressed.connect(_show_main_menu)
	_screen_root.add_child(screen)

func _show_error(message: String) -> void:
	_clear_screen()
	var label := Label.new()
	label.text = message
	label.anchor_left = 0.1
	label.anchor_top = 0.1
	ArenaStyle.style_label(label, 22, ArenaStyle.CORAL)
	_screen_root.add_child(label)

func _result_title(result: Dictionary) -> String:
	if _selected_mode == GameConstants.MODE_TEAM_ARENA:
		var winning_team := int(result.get("winning_team_id", 0))
		var session := _match_room.get_session(_local_player_id) if _match_room != null else null
		var local_team := session.team_id if session != null else GameConstants.TEAM_A
		return "Victory" if winning_team == local_team else "Defeat"
	for entry in result.get("rankings", []):
		if str(entry.get("player_id", "")) == _local_player_id:
			return "Rank %d" % int(entry.get("rank", 0))
	return "Match Result"

func _local_result_line(rankings: Array) -> String:
	for entry in rankings:
		if str(entry.get("player_id", "")) == _local_player_id:
			return "You scored %d with %d kills and %d deaths." % [int(entry.get("score", 0)), int(entry.get("kills", 0)), int(entry.get("deaths", 0))]
	return "No local score recorded."

func _result_top_lines(rankings: Array) -> String:
	var lines: Array[String] = ["Top Results"]
	var count := 0
	for entry in rankings:
		if count >= 8:
			break
		lines.append("%d. %s  score %d  K %d  D %d" % [
			int(entry.get("rank", 0)),
			str(entry.get("player_id", "")).replace(GameConstants.BOT_PREFIX, "Bot "),
			int(entry.get("score", 0)),
			int(entry.get("kills", 0)),
			int(entry.get("deaths", 0)),
		])
		count += 1
	return "\n".join(lines)

func _clear_screen() -> void:
	if _screen_root == null:
		return
	for child in _screen_root.get_children():
		child.queue_free()
	_ui_layer = null
	_paused = false
