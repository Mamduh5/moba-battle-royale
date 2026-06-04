class_name HUD
extends Control

var player_id := GameConstants.LOCAL_PLAYER_ID
var snapshot: SnapshotFrame = null
var content_db: Object = null
var _score_panel := ScorePanel.new()
var _ability_buttons: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_score_panel)
	_score_panel.anchor_left = 0.5
	_score_panel.anchor_right = 0.5
	_score_panel.offset_left = -165
	_score_panel.offset_right = 165
	_score_panel.offset_top = 16
	_score_panel.offset_bottom = 154
	for slot in [GameConstants.SLOT_BASIC, GameConstants.SLOT_ABILITY_1, GameConstants.SLOT_ULTIMATE]:
		var ability_button := AbilityButton.new()
		_ability_buttons[slot] = ability_button
		add_child(ability_button)

func set_snapshot(next_snapshot: SnapshotFrame, local_player_id: String, db: Object) -> void:
	snapshot = next_snapshot
	player_id = local_player_id
	content_db = db
	_score_panel.set_snapshot(snapshot, player_id)
	_update_ability_buttons()
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_abilities()

func _layout_abilities() -> void:
	var slots := [GameConstants.SLOT_BASIC, GameConstants.SLOT_ABILITY_1, GameConstants.SLOT_ULTIMATE]
	var total_width := slots.size() * 82
	var start_x := size.x * 0.5 - total_width * 0.5
	for i in range(slots.size()):
		var button: AbilityButton = _ability_buttons[slots[i]]
		button.position = Vector2(start_x + i * 82, size.y - 96)
		button.size = Vector2(74, 74)

func _update_ability_buttons() -> void:
	if snapshot == null or content_db == null:
		return
	var entity := snapshot.get_entity(_local_entity_id())
	if entity.is_empty():
		return
	var ability_by_slot: Dictionary = entity.get("ability_by_slot", {})
	var cooldowns: Dictionary = entity.get("cooldowns", {})
	for slot in _ability_buttons.keys():
		var button: AbilityButton = _ability_buttons[slot]
		var ability_id := str(ability_by_slot.get(slot, ""))
		var ability: AbilityDef = content_db.get_ability(ability_id)
		if ability != null:
			button.configure(slot, _slot_label(slot), ability.icon, Color(ability.vfx_color))
			button.set_cooldown(float(cooldowns.get(slot, 0.0)), max(0.01, ability.cooldown_sec))

func _draw() -> void:
	if snapshot == null:
		return
	var entity := snapshot.get_entity(_local_entity_id())
	if entity.is_empty():
		return
	var health: Dictionary = entity.get("health", {})
	var max_health: int = max(1, int(health.get("max", 1)))
	var current: int = int(health.get("current", 0))
	var health_rect := Rect2(Vector2(24, size.y - 92), Vector2(300, 28))
	draw_rect(health_rect.grow(8.0), Color("#101826", 0.84), true)
	draw_rect(health_rect, Color("#28384F"), true)
	draw_rect(Rect2(health_rect.position, Vector2(health_rect.size.x * float(current) / float(max_health), health_rect.size.y)), ArenaTheme.COLOR_GREEN, true)
	draw_rect(health_rect, ArenaTheme.COLOR_TEXT, false, 1.5)
	draw_string(get_theme_default_font(), health_rect.position + Vector2(10, 21), "%d / %d" % [current, max_health], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color("#101826"))
	var scoreboard: Dictionary = snapshot.scoreboard
	if scoreboard.get("mode_id", "") == "25_player_deathmatch":
		var rank_text := _local_rank_text(scoreboard.get("rankings", []))
		draw_string(get_theme_default_font(), Vector2(24, size.y - 112), rank_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, ArenaTheme.COLOR_GOLD)
	draw_string(get_theme_default_font(), Vector2(size.x - 210, size.y - 34), "Local server 30Hz", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15, ArenaTheme.COLOR_MUTED)

func _local_entity_id() -> int:
	if snapshot == null:
		return 0
	for entity in snapshot.entities:
		if str(entity.get("owner_player_id", "")) == player_id:
			return int(entity.get("entity_id", 0))
	return 0

func _local_rank_text(rankings: Array) -> String:
	for entry in rankings:
		if str(entry.get("player_id", "")) == player_id:
			return "RANK #%d  SCORE %d  DEATHS %d" % [int(entry.get("rank", 0)), int(entry.get("score", 0)), int(entry.get("deaths", 0))]
	return "RANKING"

func _slot_label(slot: String) -> String:
	match slot:
		GameConstants.SLOT_BASIC:
			return "M1"
		GameConstants.SLOT_ABILITY_1:
			return "E"
		GameConstants.SLOT_ULTIMATE:
			return "R"
	return slot
