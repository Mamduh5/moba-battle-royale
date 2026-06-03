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
var _pause_overlay: Control
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
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.10, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_screen_root.add_child(bg)
	var menu := MainMenuScreen.new()
	menu.quick_start_pressed.connect(func() -> void:
		_selected_mode = GameConstants.MODE_TEAM_ARENA
		_start_local_match(false)
	)
	menu.mode_select_pressed.connect(_show_mode_select)
	_screen_root.add_child(menu)

func _show_mode_select() -> void:
	_clear_screen()
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.11, 0.13)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_screen_root.add_child(bg)
	var box := VBoxContainer.new()
	box.anchor_left = 0.08
	box.anchor_top = 0.08
	box.anchor_right = 0.62
	box.anchor_bottom = 0.92
	box.add_theme_constant_override("separation", 14)
	_screen_root.add_child(box)
	var title := Label.new()
	title.text = "Mode Select"
	title.add_theme_font_size_override("font_size", 40)
	box.add_child(title)
	var mode_buttons := HBoxContainer.new()
	mode_buttons.add_theme_constant_override("separation", 10)
	box.add_child(mode_buttons)
	var team_button := Button.new()
	team_button.text = "3v3 Team Arena"
	team_button.toggle_mode = true
	team_button.button_pressed = _selected_mode == GameConstants.MODE_TEAM_ARENA
	mode_buttons.add_child(team_button)
	var dm_button := Button.new()
	dm_button.text = "25 Player Deathmatch"
	dm_button.toggle_mode = true
	dm_button.button_pressed = _selected_mode == GameConstants.MODE_DEATHMATCH
	mode_buttons.add_child(dm_button)
	team_button.pressed.connect(func() -> void:
		_selected_mode = GameConstants.MODE_TEAM_ARENA
		team_button.button_pressed = true
		dm_button.button_pressed = false
	)
	dm_button.pressed.connect(func() -> void:
		_selected_mode = GameConstants.MODE_DEATHMATCH
		team_button.button_pressed = false
		dm_button.button_pressed = true
	)
	var hero_label := Label.new()
	hero_label.text = "Hero"
	box.add_child(hero_label)
	var hero_select := OptionButton.new()
	for hero_id in ContentDB.get_all_heroes().keys():
		var hero: HeroDef = ContentDB.get_hero(str(hero_id))
		hero_select.add_item(hero.display_name)
		hero_select.set_item_metadata(hero_select.item_count - 1, hero.id)
		if hero.id == _selected_hero:
			hero_select.select(hero_select.item_count - 1)
	hero_select.item_selected.connect(func(index: int) -> void:
		_selected_hero = str(hero_select.get_item_metadata(index))
	)
	box.add_child(hero_select)
	var room_row := HBoxContainer.new()
	room_row.add_theme_constant_override("separation", 8)
	box.add_child(room_row)
	var room_field := LineEdit.new()
	room_field.custom_minimum_size = Vector2(180, 38)
	room_row.add_child(room_field)
	var host := Button.new()
	host.text = "Host Match"
	room_row.add_child(host)
	var join := Button.new()
	join.text = "Join Match"
	room_row.add_child(join)
	var code_label := Label.new()
	code_label.text = "Room Code: Local"
	box.add_child(code_label)
	host.pressed.connect(func() -> void:
		_room_code = "ROOM%04d" % (Time.get_ticks_msec() % 10000)
		code_label.text = "Room Code: %s" % _room_code
	)
	join.pressed.connect(func() -> void:
		_room_code = room_field.text.strip_edges()
		if _room_code == "":
			_room_code = "LOCAL"
		code_label.text = "Joining: %s" % _room_code
		_start_local_match(true)
	)
	var start := Button.new()
	start.text = "Start With Bots"
	start.custom_minimum_size = Vector2(280, 46)
	start.pressed.connect(func() -> void: _start_local_match(false))
	box.add_child(start)
	var back := Button.new()
	back.text = "Back"
	back.pressed.connect(_show_main_menu)
	box.add_child(back)

func _start_local_match(simulate_friend: bool) -> void:
	if not _content_ready:
		_show_error("Content validation failed. Check command output.")
		return
	_clear_screen()
	var loading := Label.new()
	loading.text = "Loading Match"
	loading.anchor_left = 0.08
	loading.anchor_top = 0.08
	loading.add_theme_font_size_override("font_size", 36)
	_screen_root.add_child(loading)
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
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	_pause_overlay.add_child(box)
	var title := Label.new()
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	box.add_child(title)
	var resume := Button.new()
	resume.text = "Resume"
	resume.pressed.connect(func() -> void: _set_paused(false))
	box.add_child(resume)
	var menu := Button.new()
	menu.text = "Return To Menu"
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
	_match_room = null
	_clear_screen()
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.10, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_screen_root.add_child(bg)
	var box := VBoxContainer.new()
	box.anchor_left = 0.1
	box.anchor_top = 0.08
	box.anchor_right = 0.72
	box.anchor_bottom = 0.92
	box.add_theme_constant_override("separation", 12)
	_screen_root.add_child(box)
	var title := Label.new()
	title.text = _result_title(result)
	title.add_theme_font_size_override("font_size", 42)
	box.add_child(title)
	var reason := Label.new()
	reason.text = "Finished by %s" % str(result.get("reason", "match end")).capitalize()
	box.add_child(reason)
	var rankings: Array = result.get("rankings", [])
	var local_line := Label.new()
	local_line.text = _local_result_line(rankings)
	box.add_child(local_line)
	var top := Label.new()
	top.text = _result_top_lines(rankings)
	top.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(top)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	box.add_child(buttons)
	var restart := Button.new()
	restart.text = "Restart"
	restart.pressed.connect(func() -> void: _start_local_match(false))
	buttons.add_child(restart)
	var menu := Button.new()
	menu.text = "Return To Menu"
	menu.pressed.connect(_show_main_menu)
	buttons.add_child(menu)

func _show_error(message: String) -> void:
	_clear_screen()
	var label := Label.new()
	label.text = message
	label.anchor_left = 0.1
	label.anchor_top = 0.1
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
