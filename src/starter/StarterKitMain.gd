extends Node2D
class_name StarterKitMain

const WORLD_SIZE := Vector2(6400.0, 4400.0)
const PLAYER_SPEED := 380.0
const SAFE_CENTER := Vector2(3740.0, 2110.0)
const SAFE_RADIUS := 1320.0
const DANGER_RADIUS := 1880.0
const CAMERA_MARGIN := 32.0

enum ScreenState {
	MAIN_MENU,
	MODE_SELECT,
	MATCH,
	RESULT
}

var _screen_state: ScreenState = ScreenState.MAIN_MENU
var _capture_locked := false
var _capture_size := Vector2i.ZERO
var _demo_time := 0.0
var _effect_timer := 0.0
var _player_pos := Vector2(2890.0, 2160.0)
var _player_velocity := Vector2.ZERO
var _aim_world := Vector2(3400.0, 2110.0)
var _camera_pos := Vector2.ZERO
var _world_pattern: Array[Dictionary] = []
var _landmarks: Array[Dictionary] = []
var _pickups: Array[Dictionary] = []
var _actors: Array[Dictionary] = []
var _effects: Array[Dictionary] = []
var _ability_names: PackedStringArray = PackedStringArray(["Rift Step", "Aegis Burst", "Stormbreak"])
var _ability_keys: PackedStringArray = PackedStringArray(["Q", "E", "R"])
var _ability_cooldowns: PackedFloat32Array = PackedFloat32Array([4.0, 6.5, 14.0])
var _ability_remaining: PackedFloat32Array = PackedFloat32Array([0.0, 0.0, 0.0])
var _font: Font
var _main_button_rect := Rect2()
var _mode_button_rect := Rect2()
var _result_button_rect := Rect2()

func _ready() -> void:
	_font = ThemeDB.fallback_font
	_setup_input_actions()
	_seed_content()
	_set_camera_from_player()
	set_process(true)
	set_physics_process(true)

func configure_for_capture(screen_name: String, size: Vector2i) -> void:
	_capture_locked = true
	_capture_size = size
	_demo_time = 38.0
	_player_pos = Vector2(3040.0, 2120.0)
	_aim_world = Vector2(3580.0, 1960.0)
	_ability_remaining = PackedFloat32Array([1.5, 0.0, 8.2])
	_set_screen_by_name(screen_name)
	_seed_content()
	_seed_capture_effects()
	_set_camera_from_player()
	queue_redraw()

func get_starter_kit_status() -> Dictionary:
	return {
		"world_size": {"x": WORLD_SIZE.x, "y": WORLD_SIZE.y},
		"viewport_reference": {"x": 1280, "y": 720},
		"screen_state": _screen_state,
		"abilities": _ability_names.size(),
		"landmarks": _landmarks.size(),
		"pickups": _pickups.size(),
		"actors": _actors.size(),
		"effects": _effects.size(),
		"safe_zone_radius": SAFE_RADIUS,
		"has_minimap": true,
		"has_directional_awareness": true,
		"starter_scope": "local visual gameplay starter-kit only"
	}

func _setup_input_actions() -> void:
	_register_key_action("move_up", [KEY_W, KEY_UP])
	_register_key_action("move_down", [KEY_S, KEY_DOWN])
	_register_key_action("move_left", [KEY_A, KEY_LEFT])
	_register_key_action("move_right", [KEY_D, KEY_RIGHT])
	_register_key_action("ability_1", [KEY_Q])
	_register_key_action("ability_2", [KEY_E])
	_register_key_action("ability_3", [KEY_R])
	_register_key_action("accept", [KEY_ENTER, KEY_SPACE])

func _register_key_action(action_name: String, key_codes: Array[int]) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for key_code in key_codes:
		var already_registered := false
		for existing_event in InputMap.action_get_events(action_name):
			if existing_event is InputEventKey and existing_event.keycode == key_code:
				already_registered = true
		if not already_registered:
			var key_event := InputEventKey.new()
			key_event.keycode = key_code
			InputMap.action_add_event(action_name, key_event)

func _seed_content() -> void:
	_world_pattern = []
	_landmarks = []
	_pickups = []
	_actors = []
	for i in range(110):
		var gx := fposmod(float(i * 541), WORLD_SIZE.x)
		var gy := fposmod(float(i * 353), WORLD_SIZE.y)
		var radius := 24.0 + float((i * 17) % 68)
		var tone := 0.5 + float((i * 23) % 45) / 100.0
		_world_pattern.append({
			"pos": Vector2(gx, gy),
			"radius": radius,
			"tone": tone,
			"kind": i % 4
		})
	_landmarks.append({"name": "Sunken Relay", "type": "relay", "pos": Vector2(1420.0, 1040.0), "color": Color(0.20, 0.78, 0.92)})
	_landmarks.append({"name": "Feral Camp", "type": "camp", "pos": Vector2(2520.0, 1560.0), "color": Color(0.96, 0.56, 0.23)})
	_landmarks.append({"name": "Shard Vault", "type": "vault", "pos": Vector2(4440.0, 1680.0), "color": Color(0.74, 0.58, 1.00)})
	_landmarks.append({"name": "Signal Shrine", "type": "shrine", "pos": Vector2(5320.0, 3240.0), "color": Color(0.52, 0.95, 0.58)})
	_landmarks.append({"name": "Storm Gate", "type": "gate", "pos": Vector2(3200.0, 3480.0), "color": Color(1.00, 0.38, 0.43)})
	for i in range(34):
		var px := 440.0 + fposmod(float(i * 719), WORLD_SIZE.x - 880.0)
		var py := 360.0 + fposmod(float(i * 431), WORLD_SIZE.y - 720.0)
		_pickups.append({
			"pos": Vector2(px, py),
			"type": "shard" if i % 3 != 0 else "heal",
			"phase": float(i) * 0.71
		})
	var hero_types := PackedStringArray(["bulwark", "shade", "arclight"])
	for i in range(18):
		var angle := float(i) * 0.62
		var ring := 720.0 + float(i % 5) * 360.0
		var pos := SAFE_CENTER + Vector2(cos(angle), sin(angle)) * ring + Vector2(float((i * 137) % 420) - 210.0, float((i * 89) % 360) - 180.0)
		pos.x = clamp(pos.x, 240.0, WORLD_SIZE.x - 240.0)
		pos.y = clamp(pos.y, 240.0, WORLD_SIZE.y - 240.0)
		_actors.append({
			"pos": pos,
			"type": hero_types[i % hero_types.size()],
			"health": 0.38 + float((i * 19) % 61) / 100.0,
			"phase": float(i) * 0.37,
			"team": "threat"
		})

func _seed_capture_effects() -> void:
	_effects = []
	_add_effect("dash", _player_pos - Vector2(130.0, 20.0), 0.0, Color(0.34, 0.78, 1.0), 120.0, Vector2(1.0, -0.1))
	_add_effect("cast", _player_pos + Vector2(310.0, -90.0), 0.15, Color(0.38, 0.85, 1.0), 180.0, Vector2.RIGHT)
	_add_effect("impact", _player_pos + Vector2(520.0, -150.0), 0.18, Color(1.0, 0.62, 0.24), 120.0, Vector2.ZERO)
	_add_effect("death", _player_pos + Vector2(-430.0, 210.0), 0.32, Color(1.0, 0.35, 0.42), 150.0, Vector2.ZERO)
	_add_effect("respawn", _player_pos + Vector2(210.0, 420.0), 0.12, Color(0.54, 1.0, 0.67), 170.0, Vector2.ZERO)
	_add_effect("ultimate", _aim_world, 0.22, Color(0.78, 0.55, 1.0), 280.0, Vector2.ZERO)

func _set_screen_by_name(screen_name: String) -> void:
	match screen_name:
		"main_menu":
			_screen_state = ScreenState.MAIN_MENU
		"mode_select":
			_screen_state = ScreenState.MODE_SELECT
		"result":
			_screen_state = ScreenState.RESULT
		_:
			_screen_state = ScreenState.MATCH

func _process(delta: float) -> void:
	if _capture_locked:
		_demo_time += delta * 0.3
	else:
		_demo_time += delta
	if _screen_state == ScreenState.MATCH:
		_process_match(delta)
	queue_redraw()

func _process_match(delta: float) -> void:
	if not _capture_locked:
		_process_player_input(delta)
	for i in range(_ability_remaining.size()):
		_ability_remaining[i] = max(0.0, _ability_remaining[i] - delta)
	for i in range(_actors.size()):
		var actor := _actors[i]
		var phase := float(actor["phase"]) + _demo_time * 0.35
		var drift := Vector2(cos(phase * 1.7), sin(phase * 1.13)) * delta * 28.0
		actor["pos"] = (actor["pos"] as Vector2) + drift
		_actors[i] = actor
	for i in range(_effects.size() - 1, -1, -1):
		var effect := _effects[i]
		effect["age"] = float(effect["age"]) + delta
		if float(effect["age"]) > float(effect["duration"]):
			_effects.remove_at(i)
		else:
			_effects[i] = effect
	if not _capture_locked:
		_effect_timer -= delta
		if _effect_timer <= 0.0:
			_effect_timer = 2.4
			_add_effect("respawn", _player_pos + Vector2(-280.0, 280.0), 0.0, Color(0.54, 1.0, 0.67), 150.0, Vector2.ZERO)
	_set_camera_from_player()

func _process_player_input(delta: float) -> void:
	var movement := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		movement.y -= 1.0
	if Input.is_action_pressed("move_down"):
		movement.y += 1.0
	if Input.is_action_pressed("move_left"):
		movement.x -= 1.0
	if Input.is_action_pressed("move_right"):
		movement.x += 1.0
	if movement.length_squared() > 0.001:
		movement = movement.normalized()
	_player_velocity = movement * PLAYER_SPEED
	_player_pos += _player_velocity * delta
	_player_pos.x = clamp(_player_pos.x, 80.0, WORLD_SIZE.x - 80.0)
	_player_pos.y = clamp(_player_pos.y, 80.0, WORLD_SIZE.y - 80.0)
	_aim_world = _screen_to_world(get_viewport().get_mouse_position())

func _input(event: InputEvent) -> void:
	if _capture_locked:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if Input.is_action_just_pressed("accept"):
			_advance_screen()
		if _screen_state == ScreenState.MATCH:
			if Input.is_action_just_pressed("ability_1"):
				_try_cast_ability(0)
			elif Input.is_action_just_pressed("ability_2"):
				_try_cast_ability(1)
			elif Input.is_action_just_pressed("ability_3"):
				_try_cast_ability(2)
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		var mouse_pos: Vector2 = mouse_event.position
		match _screen_state:
			ScreenState.MAIN_MENU:
				if _main_button_rect.has_point(mouse_pos):
					_screen_state = ScreenState.MODE_SELECT
			ScreenState.MODE_SELECT:
				if _mode_button_rect.has_point(mouse_pos):
					_screen_state = ScreenState.MATCH
			ScreenState.RESULT:
				if _result_button_rect.has_point(mouse_pos):
					_screen_state = ScreenState.MAIN_MENU
			ScreenState.MATCH:
				_try_cast_ability(1)

func _advance_screen() -> void:
	match _screen_state:
		ScreenState.MAIN_MENU:
			_screen_state = ScreenState.MODE_SELECT
		ScreenState.MODE_SELECT:
			_screen_state = ScreenState.MATCH
		ScreenState.RESULT:
			_screen_state = ScreenState.MAIN_MENU
		ScreenState.MATCH:
			_screen_state = ScreenState.RESULT

func _try_cast_ability(index: int) -> void:
	if index < 0 or index >= _ability_remaining.size():
		return
	if _ability_remaining[index] > 0.0:
		_add_effect("denied", _player_pos, 0.0, Color(1.0, 0.32, 0.34), 86.0, Vector2.ZERO)
		return
	var aim_dir := (_aim_world - _player_pos).normalized()
	if aim_dir.length_squared() < 0.01:
		aim_dir = Vector2.RIGHT
	if index == 0:
		_add_effect("dash", _player_pos, 0.0, Color(0.34, 0.78, 1.0), 160.0, aim_dir)
		_player_pos += aim_dir * 290.0
		_player_pos.x = clamp(_player_pos.x, 80.0, WORLD_SIZE.x - 80.0)
		_player_pos.y = clamp(_player_pos.y, 80.0, WORLD_SIZE.y - 80.0)
	elif index == 1:
		_add_effect("cast", _player_pos + aim_dir * 245.0, 0.0, Color(0.38, 0.85, 1.0), 210.0, aim_dir)
		_add_effect("impact", _player_pos + aim_dir * 430.0, 0.08, Color(1.0, 0.62, 0.24), 120.0, Vector2.ZERO)
	else:
		_add_effect("ultimate", _aim_world, 0.0, Color(0.78, 0.55, 1.0), 340.0, Vector2.ZERO)
		_add_effect("death", _aim_world + Vector2(-130.0, 90.0), 0.16, Color(1.0, 0.35, 0.42), 145.0, Vector2.ZERO)
	_ability_remaining[index] = _ability_cooldowns[index]
	_set_camera_from_player()

func _add_effect(kind: String, pos: Vector2, age: float, color: Color, radius: float, direction: Vector2) -> void:
	_effects.append({
		"kind": kind,
		"pos": pos,
		"age": age,
		"duration": 1.35 if kind != "ultimate" else 1.8,
		"color": color,
		"radius": radius,
		"dir": direction
	})

func _set_camera_from_player() -> void:
	var view_size := _view_size()
	_camera_pos = _player_pos - view_size * 0.5
	_camera_pos.x = clamp(_camera_pos.x, 0.0, max(0.0, WORLD_SIZE.x - view_size.x))
	_camera_pos.y = clamp(_camera_pos.y, 0.0, max(0.0, WORLD_SIZE.y - view_size.y))

func _view_size() -> Vector2:
	if _capture_size != Vector2i.ZERO:
		return Vector2(_capture_size)
	return get_viewport_rect().size

func _world_to_screen(world_pos: Vector2) -> Vector2:
	return world_pos - _camera_pos

func _screen_to_world(screen_pos: Vector2) -> Vector2:
	return screen_pos + _camera_pos

func _draw() -> void:
	match _screen_state:
		ScreenState.MAIN_MENU:
			_draw_main_menu()
		ScreenState.MODE_SELECT:
			_draw_mode_select()
		ScreenState.RESULT:
			_draw_result_screen()
		_:
			_draw_match()

func _draw_main_menu() -> void:
	var view_size := _view_size()
	_draw_menu_backdrop(view_size, 0.0)
	_draw_text("MOBA Survival", Vector2(74.0, 122.0), 58, Color(0.95, 0.98, 0.94))
	_draw_text("Starter Kit", Vector2(78.0, 166.0), 24, Color(0.42, 0.94, 0.78))
	_draw_text("Hero skill combat on a wide survival map", Vector2(80.0, 226.0), 24, Color(0.76, 0.83, 0.84))
	_main_button_rect = Rect2(Vector2(82.0, 292.0), Vector2(270.0, 62.0))
	_draw_button(_main_button_rect, "Start Sandbox", Color(0.20, 0.70, 0.78), true)
	_draw_button(Rect2(Vector2(82.0, 372.0), Vector2(270.0, 54.0)), "Visual Board", Color(0.18, 0.23, 0.27), false)
	var lineup_origin := Vector2(view_size.x * 0.57, view_size.y * 0.56)
	_draw_halo(lineup_origin + Vector2(-230.0, 60.0), 170.0, Color(0.28, 0.78, 1.0, 0.18))
	_draw_halo(lineup_origin, 210.0, Color(0.46, 1.0, 0.63, 0.18))
	_draw_halo(lineup_origin + Vector2(260.0, 40.0), 180.0, Color(0.87, 0.58, 1.0, 0.16))
	_draw_hero_silhouette(lineup_origin + Vector2(-230.0, 86.0), "bulwark", 2.05, true)
	_draw_hero_silhouette(lineup_origin + Vector2(0.0, 42.0), "shade", 2.0, false)
	_draw_hero_silhouette(lineup_origin + Vector2(260.0, 72.0), "arclight", 2.0, false)
	_draw_screen_badge(Rect2(Vector2(view_size.x - 314.0, 36.0), Vector2(246.0, 62.0)), "Local Sandbox", "visual gameplay direction")

func _draw_mode_select() -> void:
	var view_size := _view_size()
	_draw_menu_backdrop(view_size, 0.9)
	_draw_text("Mode Direction", Vector2(64.0, 78.0), 44, Color(0.95, 0.98, 0.94))
	_draw_text("Survival map scale with MOBA skill readability", Vector2(68.0, 116.0), 21, Color(0.75, 0.83, 0.86))
	var card_w: float = minf(390.0, (view_size.x - 132.0) / 3.0)
	var card_h: float = minf(440.0, view_size.y - 206.0)
	var cards_y: float = 168.0
	var card_gap: float = 24.0
	var cards_total_w: float = card_w * 3.0 + card_gap * 2.0
	var cards_x: float = maxf(64.0, (view_size.x - cards_total_w) * 0.5)
	var cards: Array[Dictionary] = [
		{"title": "Survival Sandbox", "accent": Color(0.24, 0.78, 0.86), "hero": "bulwark", "body": "wide map, camps, safe-zone pressure"},
		{"title": "Squad Arena Style", "accent": Color(0.52, 0.95, 0.58), "hero": "shade", "body": "readable allies, threats, objective lanes"},
		{"title": "BR Scale Style", "accent": Color(0.86, 0.58, 1.0), "hero": "arclight", "body": "radar pings and off-screen awareness"}
	]
	for i in range(cards.size()):
		var rect := Rect2(Vector2(cards_x + float(i) * (card_w + card_gap), cards_y), Vector2(card_w, card_h))
		var card: Dictionary = cards[i]
		var card_accent: Color = card["accent"]
		_draw_panel(rect, Color(0.07, 0.10, 0.12, 0.92), Color(card_accent, 0.68), 8, 2)
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 7.0)), card_accent)
		_draw_text(str(card["title"]), rect.position + Vector2(24.0, 52.0), 24, Color(0.95, 0.98, 0.94))
		_draw_text(str(card["body"]), rect.position + Vector2(24.0, 84.0), 17, Color(0.70, 0.79, 0.81))
		_draw_landmark_preview(rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.48), float(i), card_accent)
		_draw_hero_silhouette(rect.position + Vector2(rect.size.x * 0.5, rect.size.y - 95.0), str(card["hero"]), 1.28, i == 0)
	_mode_button_rect = Rect2(Vector2(cards_x, view_size.y - 92.0), Vector2(290.0, 56.0))
	_draw_button(_mode_button_rect, "Launch Sandbox", Color(0.20, 0.70, 0.78), true)
	_draw_screen_badge(Rect2(Vector2(view_size.x - 338.0, view_size.y - 92.0), Vector2(276.0, 56.0)), "Starter review target", "visual and gameplay direction")

func _draw_result_screen() -> void:
	var view_size := _view_size()
	_draw_menu_backdrop(view_size, 1.8)
	_draw_panel(Rect2(Vector2(view_size.x * 0.5 - 430.0, 82.0), Vector2(860.0, view_size.y - 154.0)), Color(0.055, 0.075, 0.09, 0.94), Color(0.32, 0.78, 0.82), 8, 2)
	_draw_text("Sandbox Result Direction", Vector2(view_size.x * 0.5 - 360.0, 150.0), 38, Color(0.96, 0.98, 0.94))
	_draw_text("Clear combat feedback, readable rank cards, fast return flow", Vector2(view_size.x * 0.5 - 360.0, 188.0), 20, Color(0.74, 0.83, 0.86))
	var stats: Array[Dictionary] = [
		{"label": "SHARDS", "value": "18", "color": Color(0.48, 0.92, 0.86)},
		{"label": "CAMPS", "value": "4", "color": Color(0.98, 0.61, 0.27)},
		{"label": "ZONE", "value": "SAFE", "color": Color(0.56, 0.98, 0.62)}
	]
	for i in range(stats.size()):
		var rect := Rect2(Vector2(view_size.x * 0.5 - 360.0 + float(i) * 245.0, 234.0), Vector2(208.0, 112.0))
		var stat: Dictionary = stats[i]
		var stat_color: Color = stat["color"]
		_draw_panel(rect, Color(0.08, 0.12, 0.15, 0.96), Color(stat_color, 0.72), 8, 2)
		_draw_text(str(stat["label"]), rect.position + Vector2(18.0, 32.0), 15, Color(0.68, 0.78, 0.80))
		_draw_text(str(stat["value"]), rect.position + Vector2(18.0, 78.0), 38 if i != 2 else 32, stat_color)
	var rows: Array[Dictionary] = [
		{"rank": "#1", "name": "Bulwark", "detail": "objective hold", "color": Color(0.30, 0.84, 1.0)},
		{"rank": "#2", "name": "Shade", "detail": "camp control", "color": Color(0.52, 0.95, 0.58)},
		{"rank": "#3", "name": "Arclight", "detail": "zone pressure", "color": Color(0.86, 0.58, 1.0)}
	]
	for i in range(rows.size()):
		var y := 390.0 + float(i) * 64.0
		var row: Dictionary = rows[i]
		var row_color: Color = row["color"]
		var rect := Rect2(Vector2(view_size.x * 0.5 - 360.0, y), Vector2(720.0, 48.0))
		_draw_panel(rect, Color(0.10, 0.135, 0.15, 0.92), Color(0.20, 0.26, 0.29), 6, 1)
		_draw_text(str(row["rank"]), rect.position + Vector2(20.0, 32.0), 21, row_color)
		_draw_text(str(row["name"]), rect.position + Vector2(94.0, 32.0), 21, Color(0.95, 0.98, 0.94))
		_draw_text(str(row["detail"]), rect.position + Vector2(500.0, 32.0), 18, Color(0.68, 0.78, 0.80))
	_result_button_rect = Rect2(Vector2(view_size.x * 0.5 - 146.0, view_size.y - 126.0), Vector2(292.0, 56.0))
	_draw_button(_result_button_rect, "Return to Menu", Color(0.20, 0.70, 0.78), true)

func _draw_match() -> void:
	_set_camera_from_player()
	var view_size := _view_size()
	_draw_world()
	_draw_cast_indicators()
	_draw_landmarks()
	_draw_pickups()
	_draw_actors()
	_draw_effects()
	_draw_player()
	_draw_directional_awareness()
	_draw_hud(view_size)

func _draw_world() -> void:
	var view_size := _view_size()
	draw_rect(Rect2(Vector2.ZERO, view_size), Color(0.045, 0.065, 0.073))
	var world_rect := Rect2(_world_to_screen(Vector2.ZERO), WORLD_SIZE)
	_draw_panel(world_rect, Color(0.066, 0.095, 0.082), Color(0.20, 0.38, 0.35), 4, 4)
	for x in range(0, int(WORLD_SIZE.x) + 1, 400):
		var sx := float(x) - _camera_pos.x
		draw_line(Vector2(sx, -_camera_pos.y), Vector2(sx, WORLD_SIZE.y - _camera_pos.y), Color(0.12, 0.18, 0.17, 0.38), 1.0)
	for y in range(0, int(WORLD_SIZE.y) + 1, 400):
		var sy := float(y) - _camera_pos.y
		draw_line(Vector2(-_camera_pos.x, sy), Vector2(WORLD_SIZE.x - _camera_pos.x, sy), Color(0.12, 0.18, 0.17, 0.38), 1.0)
	_draw_world_path(Vector2(220.0, 3600.0), Vector2(5900.0, 760.0), Color(0.15, 0.19, 0.16), 98.0)
	_draw_world_path(Vector2(820.0, 880.0), Vector2(5800.0, 3420.0), Color(0.14, 0.18, 0.19), 86.0)
	_draw_world_path(Vector2(3160.0, 180.0), Vector2(3520.0, 4260.0), Color(0.11, 0.16, 0.18), 58.0)
	for pattern in _world_pattern:
		var pos := _world_to_screen(pattern["pos"])
		if not Rect2(Vector2(-160.0, -160.0), view_size + Vector2(320.0, 320.0)).has_point(pos):
			continue
		var radius := float(pattern["radius"])
		var tone := float(pattern["tone"])
		var kind := int(pattern["kind"])
		var color := Color(0.08 + tone * 0.035, 0.14 + tone * 0.05, 0.11 + tone * 0.035, 0.36)
		if kind == 1:
			color = Color(0.08, 0.13 + tone * 0.05, 0.16 + tone * 0.035, 0.32)
		elif kind == 2:
			color = Color(0.13 + tone * 0.04, 0.12 + tone * 0.03, 0.08, 0.28)
		draw_circle(pos, radius, color)
		draw_arc(pos, radius, 0.0, TAU, 18, Color(0.14, 0.20, 0.18, 0.18), 1.0)
	var safe_screen := _world_to_screen(SAFE_CENTER)
	draw_circle(safe_screen, DANGER_RADIUS, Color(0.48, 0.12, 0.15, 0.045))
	draw_arc(safe_screen, DANGER_RADIUS, 0.0, TAU, 128, Color(0.95, 0.28, 0.32, 0.52), 6.0, true)
	draw_circle(safe_screen, SAFE_RADIUS, Color(0.14, 0.50, 0.44, 0.045))
	draw_arc(safe_screen, SAFE_RADIUS, 0.0, TAU, 128, Color(0.35, 0.93, 0.78, 0.80), 7.0, true)
	for i in range(26):
		var a := float(i) / 26.0 * TAU + _demo_time * 0.08
		var inner := safe_screen + Vector2(cos(a), sin(a)) * (SAFE_RADIUS - 22.0)
		var outer := safe_screen + Vector2(cos(a), sin(a)) * (SAFE_RADIUS + 20.0)
		draw_line(inner, outer, Color(0.63, 1.0, 0.85, 0.55), 3.0)

func _draw_world_path(a: Vector2, b: Vector2, color: Color, width: float) -> void:
	var points := PackedVector2Array()
	var steps := 20
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var wobble := sin(t * TAU * 1.5 + a.x * 0.01) * 120.0
		var base := a.lerp(b, t)
		var dir := (b - a).normalized()
		var normal := Vector2(-dir.y, dir.x)
		points.append(_world_to_screen(base + normal * wobble))
	draw_polyline(points, color, width, true)
	draw_polyline(points, Color(0.23, 0.30, 0.27, 0.32), max(2.0, width * 0.08), true)

func _draw_cast_indicators() -> void:
	var player_screen := _world_to_screen(_player_pos)
	var aim_screen := _world_to_screen(_aim_world)
	var aim_dir := (_aim_world - _player_pos).normalized()
	if aim_dir.length_squared() < 0.01:
		aim_dir = Vector2.RIGHT
	draw_line(player_screen, aim_screen, Color(0.65, 0.94, 1.0, 0.42), 2.0)
	draw_arc(player_screen, 290.0, aim_dir.angle() - 0.34, aim_dir.angle() + 0.34, 32, Color(0.42, 0.90, 1.0, 0.62), 4.0, true)
	draw_circle(player_screen + aim_dir * 430.0, 86.0, Color(0.30, 0.76, 1.0, 0.11))
	draw_arc(player_screen + aim_dir * 430.0, 86.0, 0.0, TAU, 42, Color(0.42, 0.90, 1.0, 0.56), 3.0, true)
	draw_circle(aim_screen, 168.0, Color(0.78, 0.55, 1.0, 0.09))
	draw_arc(aim_screen, 168.0, 0.0, TAU, 64, Color(0.78, 0.55, 1.0, 0.48), 4.0, true)

func _draw_landmarks() -> void:
	var view_size := _view_size()
	for landmark in _landmarks:
		var pos := _world_to_screen(landmark["pos"])
		if not Rect2(Vector2(-220.0, -220.0), view_size + Vector2(440.0, 440.0)).has_point(pos):
			continue
		var color := landmark["color"] as Color
		var points := PackedVector2Array([
			pos + Vector2(0.0, -52.0),
			pos + Vector2(48.0, -8.0),
			pos + Vector2(34.0, 48.0),
			pos + Vector2(-38.0, 44.0),
			pos + Vector2(-52.0, -8.0)
		])
		draw_colored_polygon(points, Color(0.02, 0.03, 0.035, 0.86))
		draw_polyline(_closed_points(points), color, 4.0, true)
		draw_circle(pos, 21.0 + sin(_demo_time * 2.0) * 3.0, Color(color, 0.32))
		draw_circle(pos, 8.0, color)
		_draw_text(str(landmark["name"]), pos + Vector2(-64.0, -66.0), 15, Color(0.86, 0.94, 0.92))

func _draw_pickups() -> void:
	var view_size := _view_size()
	for pickup in _pickups:
		var pos := _world_to_screen(pickup["pos"])
		if not Rect2(Vector2(-60.0, -60.0), view_size + Vector2(120.0, 120.0)).has_point(pos):
			continue
		var phase := float(pickup["phase"]) + _demo_time * 2.4
		var color := Color(0.43, 0.92, 0.88) if str(pickup["type"]) == "shard" else Color(0.55, 1.0, 0.60)
		var bob := sin(phase) * 4.0
		var diamond := PackedVector2Array([
			pos + Vector2(0.0, -13.0 + bob),
			pos + Vector2(12.0, 0.0 + bob),
			pos + Vector2(0.0, 13.0 + bob),
			pos + Vector2(-12.0, 0.0 + bob)
		])
		draw_colored_polygon(diamond, Color(0.02, 0.03, 0.035, 0.85))
		draw_polyline(_closed_points(diamond), color, 2.0, true)
		draw_circle(pos + Vector2(0.0, bob), 4.0, Color(color, 0.9))

func _draw_actors() -> void:
	var view_size := _view_size()
	for actor in _actors:
		var pos := _world_to_screen(actor["pos"])
		if not Rect2(Vector2(-120.0, -120.0), view_size + Vector2(240.0, 240.0)).has_point(pos):
			continue
		_draw_hero_silhouette(pos, str(actor["type"]), 0.78, false)
		_draw_health_bar(pos + Vector2(-32.0, -58.0), float(actor["health"]), Color(0.95, 0.30, 0.36))

func _draw_player() -> void:
	var player_screen := _world_to_screen(_player_pos)
	draw_arc(player_screen, 58.0 + sin(_demo_time * 4.0) * 3.0, 0.0, TAU, 48, Color(0.65, 1.0, 0.86, 0.86), 4.0, true)
	draw_arc(player_screen, 70.0, -0.7 + _demo_time * 0.8, 0.7 + _demo_time * 0.8, 34, Color(1.0, 1.0, 1.0, 0.55), 3.0, true)
	_draw_hero_silhouette(player_screen, "bulwark", 1.0, true)
	_draw_health_bar(player_screen + Vector2(-42.0, -76.0), 0.82, Color(0.54, 1.0, 0.64))

func _draw_effects() -> void:
	for effect in _effects:
		var pos: Vector2 = _world_to_screen(effect["pos"])
		var age: float = float(effect["age"])
		var duration: float = maxf(0.001, float(effect["duration"]))
		var t: float = clampf(age / duration, 0.0, 1.0)
		var color := effect["color"] as Color
		var radius: float = float(effect["radius"])
		var alpha: float = 1.0 - t
		match str(effect["kind"]):
			"dash":
				var dir := effect["dir"] as Vector2
				if dir.length_squared() < 0.01:
					dir = Vector2.RIGHT
				for i in range(4):
					var offset: Vector2 = dir.normalized() * (-radius * (float(i) * 0.22 + t))
					draw_circle(pos + offset, 36.0 * (1.0 - float(i) * 0.13), Color(color, alpha * (0.22 - float(i) * 0.035)))
				draw_line(pos - dir * radius * 0.55, pos + dir * radius * 0.45, Color(color, alpha * 0.72), 9.0)
			"cast":
				draw_circle(pos, radius * (0.42 + t * 0.34), Color(color, alpha * 0.17))
				draw_arc(pos, radius * (0.35 + t * 0.45), 0.0, TAU, 48, Color(color, alpha * 0.78), 5.0, true)
			"impact":
				for i in range(10):
					var angle := float(i) / 10.0 * TAU
					draw_line(pos, pos + Vector2(cos(angle), sin(angle)) * radius * (0.2 + t), Color(color, alpha * 0.65), 4.0)
				draw_circle(pos, 26.0 + radius * t * 0.55, Color(1.0, 0.96, 0.74, alpha * 0.20))
			"death":
				draw_arc(pos, radius * (0.25 + t * 0.75), 0.0, TAU, 36, Color(color, alpha * 0.82), 6.0, true)
				draw_line(pos + Vector2(-40.0, -40.0) * (1.0 + t), pos + Vector2(40.0, 40.0) * (1.0 + t), Color(color, alpha * 0.78), 5.0)
				draw_line(pos + Vector2(-40.0, 40.0) * (1.0 + t), pos + Vector2(40.0, -40.0) * (1.0 + t), Color(color, alpha * 0.78), 5.0)
			"respawn":
				for i in range(3):
					var r: float = radius * (t + float(i) * 0.22)
					draw_arc(pos, r, 0.0, TAU, 48, Color(color, alpha * (0.64 - float(i) * 0.13)), 4.0, true)
				draw_line(pos + Vector2(0.0, -72.0), pos + Vector2(0.0, 42.0), Color(color, alpha * 0.75), 5.0)
			"ultimate":
				draw_circle(pos, radius * 0.68, Color(color, alpha * 0.10))
				draw_arc(pos, radius * (0.5 + t * 0.35), 0.0, TAU, 96, Color(color, alpha * 0.86), 8.0, true)
				for i in range(14):
					var angle := float(i) / 14.0 * TAU + _demo_time
					draw_line(pos + Vector2(cos(angle), sin(angle)) * radius * 0.2, pos + Vector2(cos(angle), sin(angle)) * radius * 0.72, Color(color, alpha * 0.35), 3.0)
			"denied":
				draw_arc(pos, radius * (0.7 + t * 0.4), -0.8, 0.8, 24, Color(color, alpha * 0.85), 5.0, true)

func _draw_hud(view_size: Vector2) -> void:
	var top_rect := Rect2(Vector2(24.0, 20.0), Vector2(min(680.0, view_size.x - 360.0), 70.0))
	_draw_panel(top_rect, Color(0.035, 0.055, 0.065, 0.88), Color(0.20, 0.34, 0.36), 8, 2)
	_draw_text("Survival Sandbox", top_rect.position + Vector2(20.0, 30.0), 20, Color(0.95, 0.98, 0.94))
	_draw_text("Zone 02", top_rect.position + Vector2(20.0, 56.0), 16, Color(0.56, 0.94, 0.82))
	_draw_text("03:42", top_rect.position + Vector2(top_rect.size.x - 110.0, 45.0), 30, Color(0.95, 0.98, 0.94))
	var health_rect := Rect2(Vector2(28.0, view_size.y - 134.0), Vector2(330.0, 92.0))
	_draw_panel(health_rect, Color(0.035, 0.055, 0.065, 0.88), Color(0.22, 0.32, 0.34), 8, 2)
	_draw_text("BULWARK", health_rect.position + Vector2(18.0, 30.0), 18, Color(0.72, 0.92, 0.90))
	_draw_large_bar(Rect2(health_rect.position + Vector2(18.0, 44.0), Vector2(292.0, 20.0)), 0.82, Color(0.48, 1.0, 0.60), Color(0.10, 0.18, 0.16))
	_draw_large_bar(Rect2(health_rect.position + Vector2(18.0, 70.0), Vector2(292.0, 12.0)), 0.58, Color(0.30, 0.72, 1.0), Color(0.09, 0.13, 0.18))
	_draw_ability_bar(view_size)
	_draw_minimap(view_size)
	_draw_objective_stack(view_size)

func _draw_ability_bar(view_size: Vector2) -> void:
	var icon_size: float = 72.0
	var gap: float = 14.0
	var total_width: float = icon_size * 3.0 + gap * 2.0
	var start: Vector2 = Vector2(view_size.x * 0.5 - total_width * 0.5, view_size.y - 104.0)
	for i in range(3):
		var rect := Rect2(start + Vector2(float(i) * (icon_size + gap), 0.0), Vector2(icon_size, icon_size))
		var accent: Color = Color(0.34, 0.78, 1.0)
		if i == 1:
			accent = Color(0.42, 0.93, 0.76)
		elif i == 2:
			accent = Color(0.82, 0.56, 1.0)
		_draw_panel(rect, Color(0.04, 0.06, 0.07, 0.92), accent, 8, 2)
		_draw_ability_icon(rect, i, accent)
		var cd: float = _ability_remaining[i]
		if cd > 0.0:
			var pct: float = clampf(cd / _ability_cooldowns[i], 0.0, 1.0)
			draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * pct)), Color(0.0, 0.0, 0.0, 0.58))
			_draw_text(str(ceil(cd)), rect.position + Vector2(0.0, 47.0), 25, Color(0.98, 0.99, 0.94), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x)
		_draw_text(_ability_keys[i], rect.position + Vector2(6.0, 17.0), 14, Color(0.95, 0.98, 0.94))
		_draw_text(_ability_names[i], rect.position + Vector2(-18.0, 94.0), 13, Color(0.78, 0.86, 0.86), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x + 36.0)

func _draw_ability_icon(rect: Rect2, index: int, accent: Color) -> void:
	var center := rect.position + rect.size * 0.5
	if index == 0:
		draw_line(center + Vector2(-20.0, 14.0), center + Vector2(22.0, -16.0), Color(0.02, 0.03, 0.035), 11.0)
		draw_line(center + Vector2(-20.0, 14.0), center + Vector2(22.0, -16.0), accent, 7.0)
		draw_line(center + Vector2(10.0, -18.0), center + Vector2(24.0, -17.0), accent, 5.0)
		draw_line(center + Vector2(16.0, -4.0), center + Vector2(24.0, -17.0), accent, 5.0)
	elif index == 1:
		draw_arc(center, 23.0, -0.2, TAU - 0.2, 40, accent, 6.0, true)
		draw_circle(center, 9.0, Color(accent, 0.46))
		draw_line(center + Vector2(-22.0, 0.0), center + Vector2(22.0, 0.0), accent, 4.0)
	else:
		for i in range(6):
			var angle := float(i) / 6.0 * TAU
			draw_line(center, center + Vector2(cos(angle), sin(angle)) * 25.0, accent, 4.0)
		draw_circle(center, 13.0, Color(accent, 0.70))

func _draw_minimap(view_size: Vector2) -> void:
	var size := Vector2(232.0, 168.0)
	var rect := Rect2(Vector2(view_size.x - size.x - 26.0, 24.0), size)
	_draw_panel(rect, Color(0.035, 0.05, 0.055, 0.91), Color(0.24, 0.42, 0.44), 8, 2)
	_draw_text("RADAR", rect.position + Vector2(14.0, 24.0), 14, Color(0.76, 0.88, 0.88))
	var map_rect := Rect2(rect.position + Vector2(12.0, 34.0), rect.size - Vector2(24.0, 46.0))
	draw_rect(map_rect, Color(0.06, 0.11, 0.10, 0.88))
	var scale := Vector2(map_rect.size.x / WORLD_SIZE.x, map_rect.size.y / WORLD_SIZE.y)
	var safe_pos := map_rect.position + SAFE_CENTER * scale
	draw_circle(safe_pos, SAFE_RADIUS * scale.x, Color(0.30, 0.95, 0.78, 0.13))
	draw_arc(safe_pos, SAFE_RADIUS * scale.x, 0.0, TAU, 64, Color(0.35, 0.95, 0.78, 0.75), 2.0)
	draw_arc(safe_pos, DANGER_RADIUS * scale.x, 0.0, TAU, 64, Color(0.95, 0.32, 0.37, 0.55), 2.0)
	for landmark in _landmarks:
		var p := map_rect.position + (landmark["pos"] as Vector2) * scale
		draw_circle(p, 3.0, landmark["color"])
	for actor in _actors:
		var p := map_rect.position + (actor["pos"] as Vector2) * scale
		draw_circle(p, 2.0, Color(0.98, 0.35, 0.42, 0.82))
	var camera_rect := Rect2(map_rect.position + _camera_pos * scale, _view_size() * scale)
	draw_rect(camera_rect, Color(1.0, 1.0, 1.0, 0.08))
	draw_rect(camera_rect, Color(0.94, 0.99, 1.0, 0.54), false, 1.5)
	var player_p := map_rect.position + _player_pos * scale
	draw_circle(player_p, 5.0, Color(0.63, 1.0, 0.86))
	draw_arc(player_p, 8.0, 0.0, TAU, 18, Color(1.0, 1.0, 1.0, 0.85), 1.5)

func _draw_objective_stack(view_size: Vector2) -> void:
	var rect := Rect2(Vector2(view_size.x - 266.0, 214.0), Vector2(240.0, 130.0))
	if view_size.x < 1120.0:
		return
	_draw_panel(rect, Color(0.035, 0.05, 0.055, 0.86), Color(0.22, 0.32, 0.34), 8, 2)
	_draw_text("OBJECTIVES", rect.position + Vector2(14.0, 24.0), 14, Color(0.76, 0.88, 0.88))
	_draw_objective_line(rect.position + Vector2(16.0, 50.0), Color(0.96, 0.56, 0.23), "Camp", "320m")
	_draw_objective_line(rect.position + Vector2(16.0, 78.0), Color(0.74, 0.58, 1.0), "Vault", "610m")
	_draw_objective_line(rect.position + Vector2(16.0, 106.0), Color(0.35, 0.93, 0.78), "Safe", "inside")

func _draw_objective_line(pos: Vector2, color: Color, label: String, value: String) -> void:
	draw_circle(pos + Vector2(7.0, -5.0), 5.0, color)
	_draw_text(label, pos + Vector2(20.0, 0.0), 15, Color(0.90, 0.95, 0.93))
	_draw_text(value, pos + Vector2(138.0, 0.0), 15, Color(0.68, 0.78, 0.80))

func _draw_directional_awareness() -> void:
	var view_size := _view_size()
	var center := view_size * 0.5
	var targets: Array[Dictionary] = [
		{"pos": _landmarks[2]["pos"], "color": Color(0.74, 0.58, 1.0), "label": "VAULT"},
		{"pos": _landmarks[4]["pos"], "color": Color(1.00, 0.38, 0.43), "label": "GATE"}
	]
	for target: Dictionary in targets:
		var target_pos: Vector2 = target["pos"]
		var screen_pos: Vector2 = _world_to_screen(target_pos)
		if Rect2(Vector2(90.0, 105.0), view_size - Vector2(180.0, 210.0)).has_point(screen_pos):
			continue
		var dir := (screen_pos - center).normalized()
		if dir.length_squared() < 0.01:
			dir = Vector2.RIGHT
		var edge_distance: float = minf(view_size.x * 0.43, view_size.y * 0.40)
		var edge_pos: Vector2 = center + dir * edge_distance
		var angle: float = dir.angle()
		var points := PackedVector2Array([
			edge_pos + Vector2.from_angle(angle) * 18.0,
			edge_pos + Vector2.from_angle(angle + 2.45) * 16.0,
			edge_pos + Vector2.from_angle(angle - 2.45) * 16.0
		])
		draw_colored_polygon(points, Color(0.02, 0.03, 0.035, 0.86))
		draw_polyline(_closed_points(points), target["color"], 3.0, true)
		_draw_text(str(target["label"]), edge_pos + Vector2(-28.0, 40.0), 13, Color(0.88, 0.94, 0.92), HORIZONTAL_ALIGNMENT_CENTER, 56.0)

func _draw_hero_silhouette(pos: Vector2, hero_type: String, scale_value: float, local: bool) -> void:
	var accent := _hero_color(hero_type)
	var outline := Color(0.015, 0.02, 0.025, 0.98)
	if hero_type == "bulwark":
		var body := PackedVector2Array([
			pos + Vector2(-34.0, -33.0) * scale_value,
			pos + Vector2(30.0, -38.0) * scale_value,
			pos + Vector2(46.0, 4.0) * scale_value,
			pos + Vector2(24.0, 46.0) * scale_value,
			pos + Vector2(-34.0, 42.0) * scale_value,
			pos + Vector2(-48.0, 0.0) * scale_value
		])
		draw_colored_polygon(body, outline)
		draw_polyline(_closed_points(body), outline, 8.0 * scale_value, true)
		draw_colored_polygon(body, Color(0.21, 0.46, 0.58))
		draw_polyline(_closed_points(body), accent, 4.0 * scale_value, true)
		draw_arc(pos + Vector2(8.0, 8.0) * scale_value, 39.0 * scale_value, -1.15, 1.15, 28, Color(0.55, 0.95, 1.0), 7.0 * scale_value, true)
		draw_circle(pos + Vector2(4.0, -12.0) * scale_value, 12.0 * scale_value, Color(0.78, 0.96, 1.0))
	elif hero_type == "shade":
		var body2 := PackedVector2Array([
			pos + Vector2(0.0, -50.0) * scale_value,
			pos + Vector2(25.0, -8.0) * scale_value,
			pos + Vector2(12.0, 48.0) * scale_value,
			pos + Vector2(-18.0, 34.0) * scale_value,
			pos + Vector2(-24.0, -14.0) * scale_value
		])
		draw_colored_polygon(body2, outline)
		draw_polyline(_closed_points(body2), outline, 8.0 * scale_value, true)
		draw_colored_polygon(body2, Color(0.18, 0.40, 0.29))
		draw_polyline(_closed_points(body2), accent, 4.0 * scale_value, true)
		draw_line(pos + Vector2(-34.0, -4.0) * scale_value, pos + Vector2(-66.0, 26.0) * scale_value, Color(0.78, 1.0, 0.72), 7.0 * scale_value)
		draw_line(pos + Vector2(28.0, 0.0) * scale_value, pos + Vector2(66.0, -24.0) * scale_value, Color(0.78, 1.0, 0.72), 7.0 * scale_value)
		draw_circle(pos + Vector2(1.0, -17.0) * scale_value, 9.0 * scale_value, Color(0.85, 1.0, 0.78))
	else:
		var body3 := PackedVector2Array([
			pos + Vector2(-24.0, -26.0) * scale_value,
			pos + Vector2(18.0, -38.0) * scale_value,
			pos + Vector2(32.0, 22.0) * scale_value,
			pos + Vector2(0.0, 50.0) * scale_value,
			pos + Vector2(-35.0, 22.0) * scale_value
		])
		draw_colored_polygon(body3, outline)
		draw_polyline(_closed_points(body3), outline, 8.0 * scale_value, true)
		draw_colored_polygon(body3, Color(0.36, 0.25, 0.55))
		draw_polyline(_closed_points(body3), accent, 4.0 * scale_value, true)
		draw_line(pos + Vector2(37.0, 44.0) * scale_value, pos + Vector2(57.0, -58.0) * scale_value, Color(0.93, 0.76, 1.0), 7.0 * scale_value)
		draw_circle(pos + Vector2(60.0, -65.0) * scale_value, 13.0 * scale_value, Color(0.92, 0.58, 1.0))
		draw_circle(pos + Vector2(0.0, -12.0) * scale_value, 11.0 * scale_value, Color(0.97, 0.90, 1.0))
	if local:
		draw_arc(pos, 58.0 * scale_value, 0.0, TAU, 48, Color(0.95, 1.0, 0.92, 0.86), 3.0 * scale_value, true)

func _hero_color(hero_type: String) -> Color:
	match hero_type:
		"shade":
			return Color(0.54, 1.0, 0.62)
		"arclight":
			return Color(0.88, 0.62, 1.0)
		_:
			return Color(0.36, 0.82, 1.0)

func _draw_health_bar(pos: Vector2, pct: float, color: Color) -> void:
	draw_rect(Rect2(pos, Vector2(64.0, 8.0)), Color(0.02, 0.025, 0.025, 0.82))
	draw_rect(Rect2(pos + Vector2(2.0, 2.0), Vector2(60.0 * clamp(pct, 0.0, 1.0), 4.0)), color)
	draw_rect(Rect2(pos, Vector2(64.0, 8.0)), Color(0.90, 0.95, 0.92, 0.30), false, 1.0)

func _draw_large_bar(rect: Rect2, pct: float, fill: Color, back: Color) -> void:
	draw_rect(rect, back)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * clamp(pct, 0.0, 1.0), rect.size.y)), fill)
	draw_rect(rect, Color(0.92, 0.98, 0.94, 0.28), false, 1.0)

func _draw_menu_backdrop(view_size: Vector2, phase_offset: float) -> void:
	draw_rect(Rect2(Vector2.ZERO, view_size), Color(0.035, 0.052, 0.060))
	for i in range(34):
		var px := fposmod(float(i * 211), view_size.x + 260.0) - 130.0
		var py := fposmod(float(i * 137), view_size.y + 220.0) - 110.0
		var r := 30.0 + float((i * 19) % 84)
		var c := Color(0.07, 0.12, 0.13, 0.22)
		if i % 3 == 1:
			c = Color(0.10, 0.10, 0.15, 0.20)
		draw_circle(Vector2(px + sin(_demo_time + phase_offset + float(i)) * 18.0, py), r, c)
	_draw_panel(Rect2(Vector2(36.0, 36.0), view_size - Vector2(72.0, 72.0)), Color(0.02, 0.03, 0.035, 0.28), Color(0.16, 0.28, 0.30, 0.52), 8, 2)
	var safe_pos := Vector2(view_size.x * 0.76, view_size.y * 0.30)
	draw_arc(safe_pos, min(view_size.x, view_size.y) * 0.34, 0.0, TAU, 96, Color(0.36, 0.94, 0.76, 0.16), 8.0, true)
	draw_arc(safe_pos, min(view_size.x, view_size.y) * 0.45, 0.0, TAU, 96, Color(0.96, 0.28, 0.35, 0.13), 7.0, true)

func _draw_landmark_preview(center: Vector2, index: float, accent: Color) -> void:
	var rect := Rect2(center - Vector2(130.0, 78.0), Vector2(260.0, 156.0))
	_draw_panel(rect, Color(0.04, 0.07, 0.07, 0.88), Color(accent, 0.35), 7, 1)
	for i in range(4):
		var p := center + Vector2(cos(index + float(i) * 1.7), sin(index * 0.4 + float(i) * 1.3)) * Vector2(88.0, 48.0)
		draw_circle(p, 14.0, Color(accent, 0.18))
		draw_arc(p, 20.0, 0.0, TAU, 24, Color(accent, 0.52), 2.0)
	draw_line(center + Vector2(-110.0, 40.0), center + Vector2(104.0, -38.0), Color(0.24, 0.30, 0.29, 0.9), 22.0)
	draw_circle(center, 26.0, Color(accent, 0.28))
	draw_arc(center, 36.0, 0.0, TAU, 32, accent, 4.0)

func _draw_screen_badge(rect: Rect2, title: String, subtitle: String) -> void:
	_draw_panel(rect, Color(0.035, 0.052, 0.060, 0.88), Color(0.25, 0.45, 0.48), 8, 2)
	_draw_text(title, rect.position + Vector2(16.0, 25.0), 16, Color(0.94, 0.98, 0.94))
	_draw_text(subtitle, rect.position + Vector2(16.0, 47.0), 13, Color(0.66, 0.78, 0.80))

func _draw_button(rect: Rect2, label: String, accent: Color, primary: bool) -> void:
	var fill := Color(0.08, 0.12, 0.14, 0.96)
	if primary:
		fill = Color(accent.r * 0.24, accent.g * 0.24, accent.b * 0.24, 0.96)
	_draw_panel(rect, fill, accent, 8, 2)
	draw_circle(rect.position + Vector2(28.0, rect.size.y * 0.5), 9.0, Color(accent, 0.78))
	_draw_text(label, rect.position + Vector2(48.0, rect.size.y * 0.5 + 8.0), 20 if primary else 18, Color(0.96, 0.99, 0.94))

func _draw_panel(rect: Rect2, fill: Color, border: Color, radius: int, border_width: int) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.shadow_color = Color(0.0, 0.0, 0.0, 0.24)
	box.shadow_size = 5
	draw_style_box(box, rect)

func _draw_halo(center: Vector2, radius: float, color: Color) -> void:
	draw_circle(center, radius, color)
	draw_arc(center, radius * 0.82, 0.0, TAU, 64, Color(color, min(0.8, color.a + 0.18)), 3.0, true)

func _draw_text(text: String, pos: Vector2, size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1.0) -> void:
	if _font == null:
		return
	draw_string(_font, pos, text, alignment, width, size, color)

func _closed_points(points: PackedVector2Array) -> PackedVector2Array:
	var closed := PackedVector2Array(points)
	if points.size() > 0:
		closed.append(points[0])
	return closed
