class_name ArenaHUD
extends Control

var _local_player_id := ""
var _mode_id := ""
var _connection_state := "local"
var _root: Control
var _health_bar: ProgressBar
var _health_label: Label
var _health_status: Label
var _score_label: Label
var _timer_label: Label
var _rank_label: Label
var _ability_icons: Dictionary = {}
var _top_label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()

func setup(local_player_id: String, mode_id: String) -> void:
	_local_player_id = local_player_id
	_mode_id = mode_id

func set_connection_state(value: String) -> void:
	_connection_state = value

func set_snapshot(snapshot: SnapshotFrame) -> void:
	if snapshot == null:
		return
	var local_entity := snapshot.entities.filter(func(entity: Dictionary) -> bool:
		return str(entity.get("owner_player_id", "")) == _local_player_id and str(entity.get("kind", "")) == "hero"
	)
	if not local_entity.is_empty():
		var health: Dictionary = local_entity[0].get("health", {})
		var max_hp := int(health.get("max", 1))
		var current_hp := int(health.get("current", 0))
		_health_bar.max_value = max_hp
		_health_bar.value = current_hp
		_health_label.text = "%d / %d" % [current_hp, max_hp]
		_health_status.text = "LOCAL PLAYER"
		var cooldowns: Dictionary = local_entity[0].get("cooldowns", {})
		for slot in _ability_icons.keys():
			var value := float(cooldowns.get(slot, 0.0))
			var icon: AbilityIcon = _ability_icons[slot]
			icon.set_cooldown(value)
	var scoreboard: Dictionary = snapshot.scoreboard
	var remaining := int(scoreboard.get("remaining_sec", 0))
	_timer_label.text = "%02d:%02d" % [int(remaining / 60), remaining % 60]
	_score_label.text = _score_text(scoreboard)
	_rank_label.text = _rank_text(scoreboard)
	_top_label.text = _top_text(scoreboard)

func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var top_panel := PanelContainer.new()
	top_panel.name = "HudTopBar"
	top_panel.anchor_left = 0.015
	top_panel.anchor_top = 0.018
	top_panel.anchor_right = 0.985
	top_panel.anchor_bottom = 0.018
	top_panel.offset_bottom = 112
	top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ArenaStyle.style_panel_container(top_panel, Color(0.035, 0.052, 0.060, 0.88), Color(0.300, 0.930, 0.880, 0.30))
	_root.add_child(top_panel)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 18)
	top_panel.add_child(top)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(285, 86)
	left.add_theme_constant_override("separation", 5)
	top.add_child(left)
	_health_status = Label.new()
	_health_status.text = "LOCAL PLAYER"
	ArenaStyle.style_label(_health_status, 12, ArenaStyle.GOLD)
	left.add_child(_health_status)
	_health_label = Label.new()
	_health_label.text = "Health"
	ArenaStyle.style_label(_health_label, 18)
	left.add_child(_health_label)
	_health_bar = ProgressBar.new()
	_health_bar.custom_minimum_size = Vector2(285, 24)
	_health_bar.show_percentage = false
	_health_bar.add_theme_stylebox_override("background", ArenaStyle.panel(Color(0.015, 0.025, 0.030, 0.95), Color(0.160, 0.320, 0.330, 0.75), 6))
	_health_bar.add_theme_stylebox_override("fill", ArenaStyle.panel(Color(0.180, 0.890, 0.500, 0.96), Color(0.600, 1.000, 0.760, 0.90), 6, 0))
	left.add_child(_health_bar)
	var center := HBoxContainer.new()
	center.add_theme_constant_override("separation", 10)
	top.add_child(center)
	for slot in [GameConstants.SLOT_BASIC, GameConstants.SLOT_ABILITY_1, GameConstants.SLOT_ULTIMATE]:
		var icon := AbilityIcon.new()
		icon.setup(slot, _slot_label(slot), _slot_hint(slot), _slot_color(slot), _slot_cooldown_max(slot))
		center.add_child(icon)
		_ability_icons[slot] = icon
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(440, 92)
	right.add_theme_constant_override("separation", 3)
	top.add_child(right)
	_score_label = Label.new()
	_timer_label = Label.new()
	_rank_label = Label.new()
	_top_label = Label.new()
	for label in [_score_label, _timer_label, _rank_label]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		ArenaStyle.style_label(label, 18)
		right.add_child(label)
	_top_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_top_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_top_label.custom_minimum_size = Vector2(430, 24)
	ArenaStyle.style_label(_top_label, 14, ArenaStyle.TEXT_MUTED)
	right.add_child(_top_label)

func _slot_label(slot: String) -> String:
	match slot:
		GameConstants.SLOT_BASIC:
			return "Basic"
		GameConstants.SLOT_ABILITY_1:
			return "Skill"
		GameConstants.SLOT_ULTIMATE:
			return "Ultimate"
	return slot.capitalize()

func _slot_hint(slot: String) -> String:
	match slot:
		GameConstants.SLOT_BASIC:
			return "LMB"
		GameConstants.SLOT_ABILITY_1:
			return "Q"
		GameConstants.SLOT_ULTIMATE:
			return "R"
	return ""

func _slot_color(slot: String) -> Color:
	match slot:
		GameConstants.SLOT_BASIC:
			return ArenaStyle.BLUE
		GameConstants.SLOT_ABILITY_1:
			return ArenaStyle.GREEN
		GameConstants.SLOT_ULTIMATE:
			return ArenaStyle.GOLD
	return ArenaStyle.LINE

func _slot_cooldown_max(slot: String) -> float:
	match slot:
		GameConstants.SLOT_BASIC:
			return 1.4
		GameConstants.SLOT_ABILITY_1:
			return 8.0
		GameConstants.SLOT_ULTIMATE:
			return 22.0
	return 5.0

func _score_text(scoreboard: Dictionary) -> String:
	if _mode_id == GameConstants.MODE_TEAM_ARENA:
		var teams: Dictionary = scoreboard.get("teams", {})
		var a: Dictionary = teams.get(str(GameConstants.TEAM_A), {})
		var b: Dictionary = teams.get(str(GameConstants.TEAM_B), {})
		return "Team Arena  %d - %d" % [int(a.get("score", 0)), int(b.get("score", 0))]
	var stats: Dictionary = scoreboard.get("player_results", {}).get(_local_player_id, {})
	return "Deathmatch  Score %d  Deaths %d" % [int(stats.get("score", 0)), int(stats.get("deaths", 0))]

func _rank_text(scoreboard: Dictionary) -> String:
	if _mode_id != GameConstants.MODE_DEATHMATCH:
		return "Connection %s" % _connection_state.capitalize()
	for entry in scoreboard.get("rankings", []):
		if str(entry.get("player_id", "")) == _local_player_id:
			var rankings: Array = scoreboard.get("rankings", [])
			return "Rank %d / %d" % [int(entry.get("rank", 0)), rankings.size()]
	return "Rank --"

func _top_text(scoreboard: Dictionary) -> String:
	if _mode_id != GameConstants.MODE_DEATHMATCH:
		return ""
	var parts: Array[String] = []
	var count := 0
	for entry in scoreboard.get("rankings", []):
		if count >= 5:
			break
		parts.append("%d. %s %d" % [int(entry.get("rank", 0)), str(entry.get("player_id", "")).replace(GameConstants.BOT_PREFIX, "B"), int(entry.get("score", 0))])
		count += 1
	return "Top 5  " + "   ".join(parts)
