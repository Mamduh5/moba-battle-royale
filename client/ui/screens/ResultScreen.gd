class_name ResultScreen
extends Control

signal restart_pressed
signal menu_pressed

var _result: Dictionary = {}
var _mode_id := GameConstants.MODE_TEAM_ARENA
var _local_player_id := GameConstants.LOCAL_PLAYER_ID
var _local_team := GameConstants.TEAM_A

func setup(result: Dictionary, mode_id: String, local_player_id: String, local_team: int = GameConstants.TEAM_A) -> void:
	_result = result.duplicate(true)
	_mode_id = mode_id
	_local_player_id = local_player_id
	_local_team = local_team
	if is_inside_tree():
		_rebuild()

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
	var bg := ArenaBackdrop.new()
	bg.variant = "result"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var shell := MarginContainer.new()
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.add_theme_constant_override("margin_left", 92)
	shell.add_theme_constant_override("margin_top", 70)
	shell.add_theme_constant_override("margin_right", 92)
	shell.add_theme_constant_override("margin_bottom", 60)
	add_child(shell)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	shell.add_child(columns)
	var summary := PanelContainer.new()
	summary.custom_minimum_size = Vector2(560, 0)
	ArenaStyle.style_panel_container(summary, Color(0.045, 0.070, 0.080, 0.94), Color(1.000, 0.765, 0.275, 0.42))
	columns.add_child(summary)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	summary.add_child(box)
	var eyebrow := Label.new()
	eyebrow.text = "MATCH COMPLETE"
	ArenaStyle.style_label(eyebrow, 13, ArenaStyle.GOLD)
	box.add_child(eyebrow)
	var title := Label.new()
	title.text = _result_title()
	ArenaStyle.style_label(title, 52, ArenaStyle.TEXT)
	box.add_child(title)
	var reason := Label.new()
	reason.text = "Finished by %s" % str(_result.get("reason", "match end")).capitalize()
	ArenaStyle.style_label(reason, 20, ArenaStyle.TEXT_MUTED)
	box.add_child(reason)
	var local := Label.new()
	local.text = _local_result_line()
	local.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ArenaStyle.style_label(local, 23)
	box.add_child(local)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	box.add_child(buttons)
	var restart := Button.new()
	restart.text = "Restart"
	ArenaStyle.style_button(restart, "primary", Vector2(150, 48))
	restart.pressed.connect(func() -> void: restart_pressed.emit())
	buttons.add_child(restart)
	var menu := Button.new()
	menu.text = "Return To Menu"
	ArenaStyle.style_button(menu, "secondary", Vector2(190, 48))
	menu.pressed.connect(func() -> void: menu_pressed.emit())
	buttons.add_child(menu)
	var table := PanelContainer.new()
	table.custom_minimum_size = Vector2(520, 0)
	ArenaStyle.style_panel_container(table, Color(0.035, 0.052, 0.060, 0.92), Color(0.300, 0.930, 0.880, 0.28))
	columns.add_child(table)
	var table_box := VBoxContainer.new()
	table_box.add_theme_constant_override("separation", 9)
	table.add_child(table_box)
	var top_title := Label.new()
	top_title.text = "Top Results"
	ArenaStyle.style_label(top_title, 26)
	table_box.add_child(top_title)
	var rankings: Array = _result.get("rankings", [])
	for i in range(min(8, rankings.size())):
		_add_rank_row(table_box, rankings[i])

func _add_rank_row(parent: Node, entry: Dictionary) -> void:
	var row := PanelContainer.new()
	var is_local := str(entry.get("player_id", "")) == _local_player_id
	ArenaStyle.style_panel_container(row, Color(0.090, 0.120, 0.095, 0.92) if is_local else Color(0.055, 0.075, 0.082, 0.74), ArenaStyle.GOLD if is_local else Color(0.180, 0.360, 0.370, 0.55))
	parent.add_child(row)
	var label := Label.new()
	label.text = "%2d   %-12s   score %2d   K %2d   D %2d" % [
		int(entry.get("rank", 0)),
		_display_player(str(entry.get("player_id", ""))),
		int(entry.get("score", 0)),
		int(entry.get("kills", 0)),
		int(entry.get("deaths", 0)),
	]
	ArenaStyle.style_label(label, 17, ArenaStyle.TEXT if is_local else ArenaStyle.TEXT_MUTED)
	row.add_child(label)

func _result_title() -> String:
	if _mode_id == GameConstants.MODE_TEAM_ARENA:
		var winning_team := int(_result.get("winning_team_id", 0))
		return "Victory" if winning_team == _local_team else "Defeat"
	for entry in _result.get("rankings", []):
		if str(entry.get("player_id", "")) == _local_player_id:
			return "Rank %d" % int(entry.get("rank", 0))
	return "Match Result"

func _local_result_line() -> String:
	for entry in _result.get("rankings", []):
		if str(entry.get("player_id", "")) == _local_player_id:
			return "You scored %d with %d kills and %d deaths." % [int(entry.get("score", 0)), int(entry.get("kills", 0)), int(entry.get("deaths", 0))]
	return "No local score recorded."

func _display_player(player_id: String) -> String:
	return player_id.replace(GameConstants.BOT_PREFIX, "Bot ")
