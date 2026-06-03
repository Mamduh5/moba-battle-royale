class_name RenderedUiAuditCommand
extends RefCounted

const ARTIFACT_ROOT := "qa_artifacts/rendered_ui"

var _tree: SceneTree
var _content_db: Object
var _audit_errors: Array[String] = []
var _captures: Array[String] = []

func run_async(args: Dictionary, content_db: Object, tree: SceneTree) -> int:
	_tree = tree
	_content_db = content_db
	_content_db.load_all()
	var validation_errors: Array[String] = _content_db.validate_all()
	if not validation_errors.is_empty():
		for error in validation_errors:
			printerr("rendered_ui_content_error: %s" % error)
		return ProtocolConstants.EXIT_CONTENT_VALIDATION_FAILURE
	_prepare_artifact_dirs()
	var sizes := [Vector2i(1280, 720), Vector2i(1920, 1080)]
	for size in sizes:
		await _capture_resolution(size)
	var report := {
		"captures": _captures,
		"errors": _audit_errors,
		"checked_at_ms": Time.get_ticks_msec(),
	}
	var report_path := ARTIFACT_ROOT + "/ui_geometry_report.json"
	var file := FileAccess.open(report_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "\t"))
	if not _audit_errors.is_empty():
		for error in _audit_errors:
			printerr("rendered_ui_audit_error: %s" % error)
		return ProtocolConstants.EXIT_GENERIC_FAILURE
	print("rendered-ui-audit: ok captures=%d report=%s" % [_captures.size(), report_path])
	return ProtocolConstants.EXIT_SUCCESS

func _capture_resolution(size: Vector2i) -> void:
	_tree.root.size = size
	DisplayServer.window_set_size(size)
	await _tree.process_frame
	await _capture_main_menu(size)
	await _capture_mode_select(size)
	await _capture_match(size, GameConstants.MODE_TEAM_ARENA, "3v3")
	await _capture_match(size, GameConstants.MODE_DEATHMATCH, "deathmatch")

func _capture_main_menu(size: Vector2i) -> void:
	var stage := _make_stage(size)
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.10, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.add_child(bg)
	var menu := MainMenuScreen.new()
	menu.size = Vector2(size)
	stage.add_child(menu)
	await _settle_frames(3)
	_audit_controls(stage, "main_menu", size)
	await _save_capture(stage, size, "main_menu")

func _capture_mode_select(size: Vector2i) -> void:
	var stage := _make_stage(size)
	_build_mode_select(stage)
	await _settle_frames(4)
	_audit_controls(stage, "mode_select", size)
	await _save_capture(stage, size, "mode_select")

func _capture_match(size: Vector2i, mode_id: String, prefix: String) -> void:
	var hud_stage := _make_stage(size)
	var mode: ModeDef = _content_db.get_mode(mode_id)
	var map: MapDef = _content_db.get_map(mode.map_id)
	var room := MatchRoom.new()
	room.configure({"mode_id": mode_id, "match_id": "render_%s_%d" % [mode_id, Time.get_ticks_msec()], "seed": 53001}, _content_db)
	room.add_session(ClientSession.human(GameConstants.LOCAL_PLAYER_ID, GameConstants.DEFAULT_HERO))
	room.start_match()
	var match_scene: MatchScene = load("res://scenes/client/MatchScene.tscn").instantiate()
	match_scene.setup(map, GameConstants.LOCAL_PLAYER_ID)
	hud_stage.add_child(match_scene)
	var hud: ArenaHUD = load("res://scenes/ui/HUD.tscn").instantiate()
	hud.setup(GameConstants.LOCAL_PLAYER_ID, mode_id)
	var ui_layer := CanvasLayer.new()
	ui_layer.name = "RenderedAuditUiLayer"
	hud_stage.add_child(ui_layer)
	ui_layer.add_child(hud)
	var saw_combat := false
	for i in range(180):
		room.tick(1.0 / 30.0)
		var snapshot := room.get_last_snapshot()
		snapshot.events = room.get_last_events()
		for event in snapshot.events:
			if str(event.get("type", "")) == "damage_applied" or str(event.get("type", "")) == "ability_cast":
				saw_combat = true
		match_scene.apply_snapshot(snapshot)
		hud.set_snapshot(snapshot)
		await _tree.process_frame
		if saw_combat and i > 60:
			break
	if not saw_combat:
		_audit_errors.append("%s did not show combat events before HUD capture" % mode_id)
	_audit_gameplay_snapshot(room.get_last_snapshot(), mode_id)
	_audit_controls(hud_stage, "%s_hud_mid_match" % prefix, size)
	await _save_capture(hud_stage, size, "%s_hud_mid_match" % prefix)
	var max_ticks := mode.duration_sec * 30 + 900
	var ticks := 0
	while not room.is_finished() and ticks < max_ticks:
		room.tick(1.0 / 30.0)
		ticks += 1
	if not room.is_finished():
		_audit_errors.append("%s did not finish for rendered result capture" % mode_id)
	var result_stage := _make_stage(size)
	_build_result_screen(result_stage, room.build_result(), mode_id)
	await _settle_frames(4)
	_audit_controls(result_stage, "%s_result" % prefix, size)
	await _save_capture(result_stage, size, "%s_result" % prefix)

func _make_stage(size: Vector2i) -> Control:
	_clear_root()
	var stage := Control.new()
	stage.name = "RenderedAuditStage"
	stage.set_anchors_preset(Control.PRESET_TOP_LEFT)
	stage.size = Vector2(size)
	_tree.root.add_child(stage)
	return stage

func _clear_root() -> void:
	for child in _tree.root.get_children():
		if child.name in ["GameConfig", "ContentDB", "DebugBus", "Protocol"]:
			continue
		child.queue_free()

func _settle_frames(count: int) -> void:
	for _i in range(count):
		await _tree.process_frame
		RenderingServer.force_draw()

func _save_capture(node: CanvasItem, size: Vector2i, name: String) -> void:
	await _tree.process_frame
	RenderingServer.force_draw()
	var image := _tree.root.get_texture().get_image()
	if image == null or image.is_empty():
		_audit_errors.append("capture %s at %s produced an empty image" % [name, str(size)])
		return
	var rel_dir := "%dx%d" % [size.x, size.y]
	var dir_path := ARTIFACT_ROOT + "/" + rel_dir
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_path))
	var path := dir_path + "/" + name + ".png"
	var error := image.save_png(path)
	if error != OK:
		_audit_errors.append("capture %s failed save_png error=%d" % [path, error])
		return
	_captures.append(path)
	node.queue_free()

func _audit_controls(root: Node, label: String, size: Vector2i) -> void:
	var controls: Array[Control] = []
	_collect_controls(root, controls)
	var viewport_rect := Rect2(Vector2.ZERO, Vector2(size))
	for control in controls:
		if not control.visible:
			continue
		var rect := control.get_global_rect()
		if rect.size.x < 1.0 or rect.size.y < 1.0:
			_audit_errors.append("%s: tiny or zero control %s rect=%s" % [label, control.name, str(rect)])
		if not viewport_rect.encloses(rect) and not rect.intersection(viewport_rect).has_area():
			_audit_errors.append("%s: control outside viewport %s rect=%s" % [label, control.name, str(rect)])
		if control is Label or control is Button:
			var min_size := control.get_combined_minimum_size()
			if min_size.x > rect.size.x + 4.0 or min_size.y > rect.size.y + 4.0:
				_audit_errors.append("%s: text may clip in %s min=%s rect=%s text=%s" % [label, control.name, str(min_size), str(rect), _control_text(control)])
	var central_focus := Rect2(Vector2(size.x * 0.25, size.y * 0.24), Vector2(size.x * 0.5, size.y * 0.52))
	for control in controls:
		if label.contains("hud") and control.visible and control.get_global_rect().intersection(central_focus).has_area() and _is_hud_control(control):
			_audit_errors.append("%s: HUD/control intersects gameplay focus %s rect=%s" % [label, control.name, str(control.get_global_rect())])
	_audit_sibling_overlaps(root, label)

func _build_mode_select(stage: Control) -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.11, 0.13)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.add_child(bg)
	var box := VBoxContainer.new()
	box.anchor_left = 0.08
	box.anchor_top = 0.08
	box.anchor_right = 0.62
	box.anchor_bottom = 0.92
	box.add_theme_constant_override("separation", 14)
	stage.add_child(box)
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
	team_button.button_pressed = true
	mode_buttons.add_child(team_button)
	var dm_button := Button.new()
	dm_button.text = "25 Player Deathmatch"
	dm_button.toggle_mode = true
	mode_buttons.add_child(dm_button)
	var hero_label := Label.new()
	hero_label.text = "Hero"
	box.add_child(hero_label)
	var hero_select := OptionButton.new()
	for hero_id in _content_db.get_all_heroes().keys():
		var hero: HeroDef = _content_db.get_hero(str(hero_id))
		hero_select.add_item(hero.display_name)
	box.add_child(hero_select)
	var room_row := HBoxContainer.new()
	room_row.add_theme_constant_override("separation", 8)
	box.add_child(room_row)
	var room_field := LineEdit.new()
	room_field.text = "LOCAL"
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
	var start := Button.new()
	start.text = "Start With Bots"
	start.custom_minimum_size = Vector2(280, 46)
	box.add_child(start)
	var back := Button.new()
	back.text = "Back"
	box.add_child(back)

func _build_result_screen(stage: Control, result: Dictionary, mode_id: String) -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.10, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.add_child(bg)
	var box := VBoxContainer.new()
	box.anchor_left = 0.1
	box.anchor_top = 0.08
	box.anchor_right = 0.72
	box.anchor_bottom = 0.92
	box.add_theme_constant_override("separation", 12)
	stage.add_child(box)
	var title := Label.new()
	title.text = _result_title(result, mode_id)
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
	buttons.add_child(restart)
	var menu := Button.new()
	menu.text = "Return To Menu"
	buttons.add_child(menu)

func _result_title(result: Dictionary, mode_id: String) -> String:
	if mode_id == GameConstants.MODE_TEAM_ARENA:
		return "Victory" if int(result.get("winning_team_id", GameConstants.TEAM_A)) == GameConstants.TEAM_A else "Defeat"
	for entry in result.get("rankings", []):
		if str(entry.get("player_id", "")) == GameConstants.LOCAL_PLAYER_ID:
			return "Rank %d" % int(entry.get("rank", 0))
	return "Match Result"

func _local_result_line(rankings: Array) -> String:
	for entry in rankings:
		if str(entry.get("player_id", "")) == GameConstants.LOCAL_PLAYER_ID:
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

func _audit_sibling_overlaps(node: Node, label: String) -> void:
	var visible_controls: Array[Control] = []
	for child in node.get_children():
		if child is Control and child.visible and not _is_background_control(child):
			visible_controls.append(child)
	for i in range(visible_controls.size()):
		for j in range(i + 1, visible_controls.size()):
			var a := visible_controls[i]
			var b := visible_controls[j]
			if a.get_parent() is Container or b.get_parent() is Container:
				continue
			var overlap := a.get_global_rect().intersection(b.get_global_rect())
			if overlap.has_area() and overlap.get_area() > 24.0:
				_audit_errors.append("%s: overlapping sibling controls %s and %s overlap=%s" % [label, a.name, b.name, str(overlap)])
	for child in node.get_children():
		_audit_sibling_overlaps(child, label)

func _collect_controls(node: Node, out: Array[Control]) -> void:
	for child in node.get_children():
		if child is Control:
			out.append(child)
		_collect_controls(child, out)

func _audit_gameplay_snapshot(snapshot: SnapshotFrame, mode_id: String) -> void:
	if snapshot == null:
		_audit_errors.append("%s: missing snapshot for gameplay readability audit" % mode_id)
		return
	var local_count := 0
	var projectile_count := 0
	var alive_count := 0
	for entity in snapshot.entities:
		if str(entity.get("owner_player_id", "")) == GameConstants.LOCAL_PLAYER_ID:
			local_count += 1
		if str(entity.get("kind", "")) == "projectile":
			projectile_count += 1
		if str(entity.get("kind", "")) == "hero" and bool(entity.get("alive", false)):
			alive_count += 1
	if local_count <= 0:
		_audit_errors.append("%s: local player not present in rendered snapshot" % mode_id)
	if alive_count < 2:
		_audit_errors.append("%s: not enough visible live heroes in rendered snapshot" % mode_id)
	if mode_id == GameConstants.MODE_DEATHMATCH and alive_count < 15:
		_audit_errors.append("deathmatch: too few live participants visible/readable, count=%d" % alive_count)

func _is_background_control(control: Control) -> bool:
	return control is ColorRect and control.get_global_rect().size.length() > 600.0

func _is_hud_control(control: Control) -> bool:
	return control is Label or control is ProgressBar or control is Button

func _control_text(control: Control) -> String:
	if control is Label:
		return (control as Label).text
	if control is Button:
		return (control as Button).text
	return control.name

func _prepare_artifact_dirs() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ARTIFACT_ROOT + "/1280x720"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ARTIFACT_ROOT + "/1920x1080"))
