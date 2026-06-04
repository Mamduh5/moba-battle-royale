class_name ClientApp
extends Control

var _current: Node = null
var _last_mode_id := "3v3_team_arena"
var _room_code := "LOCAL-ARENA"

func _ready() -> void:
	theme = ArenaTheme.create_theme()
	ContentDB.load_all()
	show_main_menu()

func show_main_menu() -> void:
	_clear_current()
	var menu := MainMenu.new()
	menu.quick_start_requested.connect(func() -> void: start_match("3v3_team_arena"))
	menu.mode_select_requested.connect(show_mode_select)
	menu.host_requested.connect(show_mode_select)
	menu.join_requested.connect(func(code: String) -> void:
		_room_code = code if code != "" else "LOCAL-ARENA"
		show_mode_select()
	)
	_set_current(menu)

func show_mode_select() -> void:
	_clear_current()
	var select := ModeSelect.new()
	select.mode_selected.connect(start_match)
	select.back_requested.connect(show_main_menu)
	_set_current(select)

func start_match(mode_id: String) -> void:
	_last_mode_id = mode_id
	_clear_current()
	var match_scene := MatchScene.new()
	match_scene.match_finished.connect(show_result)
	match_scene.menu_requested.connect(show_main_menu)
	_set_current(match_scene)
	match_scene.configure_match(mode_id, "hero_guardian", _room_code)

func show_result(result: Dictionary) -> void:
	_clear_current()
	var screen := ResultScreen.new()
	screen.restart_requested.connect(func(mode_id: String) -> void: start_match(mode_id))
	screen.menu_requested.connect(show_main_menu)
	_set_current(screen)
	screen.show_result(result, GameConstants.LOCAL_PLAYER_ID)

func _set_current(node: Control) -> void:
	_current = node
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(node)

func _clear_current() -> void:
	if _current != null:
		_current.queue_free()
		_current = null
