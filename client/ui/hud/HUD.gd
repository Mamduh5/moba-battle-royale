class_name ArenaHUD
extends Control

var _local_player_id := ""
var _mode_id := ""
var _connection_state := "local"
var _root: VBoxContainer
var _health_bar: ProgressBar
var _health_label: Label
var _score_label: Label
var _timer_label: Label
var _rank_label: Label
var _cooldown_labels: Dictionary = {}
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
		var cooldowns: Dictionary = local_entity[0].get("cooldowns", {})
		for slot in _cooldown_labels.keys():
			var value := float(cooldowns.get(slot, 0.0))
			_cooldown_labels[slot].text = _slot_label(slot) + ("\n%.1f" % value if value > 0.05 else "\nReady")
	var scoreboard: Dictionary = snapshot.scoreboard
	var remaining := int(scoreboard.get("remaining_sec", 0))
	_timer_label.text = "%02d:%02d" % [int(remaining / 60), remaining % 60]
	_score_label.text = _score_text(scoreboard)
	_rank_label.text = _rank_text(scoreboard)
	_top_label.text = _top_text(scoreboard)

func _build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_root = VBoxContainer.new()
	_root.anchor_left = 0.0
	_root.anchor_top = 0.0
	_root.anchor_right = 1.0
	_root.anchor_bottom = 0.0
	_root.offset_left = 18
	_root.offset_top = 12
	_root.offset_right = -18
	_root.offset_bottom = 130
	add_child(_root)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	_root.add_child(top)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(260, 78)
	top.add_child(left)
	_health_label = Label.new()
	_health_label.text = "Health"
	left.add_child(_health_label)
	_health_bar = ProgressBar.new()
	_health_bar.custom_minimum_size = Vector2(260, 22)
	_health_bar.show_percentage = false
	left.add_child(_health_bar)
	var center := HBoxContainer.new()
	center.add_theme_constant_override("separation", 8)
	top.add_child(center)
	for slot in [GameConstants.SLOT_BASIC, GameConstants.SLOT_ABILITY_1, GameConstants.SLOT_ULTIMATE]:
		var label := Label.new()
		label.custom_minimum_size = Vector2(86, 50)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", Color(0.93, 0.97, 0.96))
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
		center.add_child(label)
		_cooldown_labels[slot] = label
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(280, 100)
	top.add_child(right)
	_score_label = Label.new()
	_timer_label = Label.new()
	_rank_label = Label.new()
	_top_label = Label.new()
	for label in [_score_label, _timer_label, _rank_label, _top_label]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		right.add_child(label)

func _slot_label(slot: String) -> String:
	match slot:
		GameConstants.SLOT_BASIC:
			return "Basic"
		GameConstants.SLOT_ABILITY_1:
			return "Skill"
		GameConstants.SLOT_ULTIMATE:
			return "Ultimate"
	return slot.capitalize()

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
