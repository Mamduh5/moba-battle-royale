class_name GameWorldView
extends Control

var snapshot: SnapshotFrame = null
var map_def: MapDef = null
var local_player_id := GameConstants.LOCAL_PLAYER_ID
var zoom := 0.72
var _events: Array[Dictionary] = []

func set_world(next_snapshot: SnapshotFrame, next_map: MapDef, player_id: String) -> void:
	snapshot = next_snapshot
	map_def = next_map
	local_player_id = player_id
	_events = next_snapshot.events.duplicate(true)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), ArenaTheme.COLOR_BG, true)
	if snapshot == null or map_def == null:
		return
	var local_entity := _local_entity()
	var camera: Vector2 = _dict_to_vec2(local_entity.get("position", {})) if not local_entity.is_empty() else Vector2.ZERO
	_draw_arena(camera)
	for entity in snapshot.entities:
		_draw_entity(entity, camera)
	for event in _events:
		_draw_event(event, camera)

func _world_to_screen(world_pos: Vector2, camera: Vector2) -> Vector2:
	return size * 0.5 + (world_pos - camera) * zoom

func _draw_arena(camera: Vector2) -> void:
	var bounds := map_def.get_bounds_rect()
	var top_left := _world_to_screen(bounds.position, camera)
	var arena_rect := Rect2(top_left, bounds.size * zoom)
	draw_rect(arena_rect, Color("#182235"), true)
	for i in range(12):
		var x := arena_rect.position.x + float(i) * arena_rect.size.x / 12.0
		draw_line(Vector2(x, arena_rect.position.y), Vector2(x, arena_rect.end.y), Color("#263E57", 0.42), 1.0)
	for j in range(8):
		var y := arena_rect.position.y + float(j) * arena_rect.size.y / 8.0
		draw_line(Vector2(arena_rect.position.x, y), Vector2(arena_rect.end.x, y), Color("#263E57", 0.42), 1.0)
	draw_rect(arena_rect, ArenaTheme.COLOR_BLUE, false, 4.0)
	for objective in map_def.objectives:
		var center := _world_to_screen(Vector2(float(objective.get("x", 0.0)), float(objective.get("y", 0.0))), camera)
		var radius := float(objective.get("radius", 70.0)) * zoom
		draw_circle(center, radius, Color("#F8D85D", 0.08))
		draw_arc(center, radius, 0.0, TAU, 64, ArenaTheme.COLOR_GOLD, 2.0)
	for obstacle in map_def.obstacles:
		var rect := Rect2(_world_to_screen(Vector2(float(obstacle.get("x", 0.0)), float(obstacle.get("y", 0.0))), camera), Vector2(float(obstacle.get("w", 0.0)), float(obstacle.get("h", 0.0))) * zoom)
		draw_rect(rect.grow(4.0), Color("#0B1020", 0.55), true)
		draw_rect(rect, Color(map_def.wall_color), true)
		draw_rect(rect, Color("#88B5D6", 0.55), false, 2.0)

func _draw_entity(entity: Dictionary, camera: Vector2) -> void:
	var pos := _world_to_screen(_dict_to_vec2(entity.get("position", {})), camera)
	var is_local := str(entity.get("owner_player_id", "")) == local_player_id
	var team_id := int(entity.get("team_id", 0))
	var base_color: Color = Color(str(entity.get("primary_color", "#FFFFFF")))
	if not is_local and snapshot.scoreboard.get("mode_id", "") == "3v3_team_arena":
		base_color = ArenaTheme.team_color(team_id)
	var radius := 23.0 if is_local else 17.0
	if is_local:
		draw_circle(pos, radius + 13.0, Color("#FFFFFF", 0.10))
		draw_arc(pos, radius + 12.0, 0.0, TAU, 48, ArenaTheme.COLOR_GOLD, 4.0)
	elif pos.distance_to(size * 0.5) > 420.0:
		draw_circle(pos, 7.0, Color(base_color.r, base_color.g, base_color.b, 0.82))
		return
	var status: Array = entity.get("status_tags", [])
	if status.has(GameConstants.STATUS_DEAD):
		draw_line(pos + Vector2(-16, -16), pos + Vector2(16, 16), Color("#F4F7FB", 0.55), 4.0)
		draw_line(pos + Vector2(-16, 16), pos + Vector2(16, -16), Color("#F4F7FB", 0.55), 4.0)
		return
	_draw_hero_shape(pos, radius, str(entity.get("silhouette", "shield")), base_color, Color(str(entity.get("accent_color", "#FFFFFF"))), entity)
	_draw_health_bar(entity, pos + Vector2(-26, -34))
	var name_color := ArenaTheme.COLOR_TEXT if is_local else ArenaTheme.COLOR_MUTED
	draw_string(get_theme_default_font(), pos + Vector2(-34, 39), str(entity.get("display_name", "")), HORIZONTAL_ALIGNMENT_CENTER, 68.0, 11, name_color)

func _draw_hero_shape(pos: Vector2, radius: float, silhouette: String, base_color: Color, accent: Color, entity: Dictionary) -> void:
	var facing := _dict_to_vec2(entity.get("facing", {"x": 1.0, "y": 0.0}))
	if facing.length() == 0.0:
		facing = Vector2.RIGHT
	facing = facing.normalized()
	match silhouette:
		"shield":
			var points := PackedVector2Array([pos + Vector2(0, -radius * 1.15), pos + Vector2(radius, -radius * 0.25), pos + Vector2(radius * 0.65, radius), pos, pos + Vector2(-radius * 0.65, radius), pos + Vector2(-radius, -radius * 0.25)])
			draw_colored_polygon(points, base_color)
			var closed := points.duplicate()
			closed.append(points[0])
			draw_polyline(closed, Color("#101826"), 3.0)
			draw_line(pos, pos + facing * (radius + 8.0), accent, 4.0)
		"blade":
			var side := Vector2(-facing.y, facing.x)
			var points := PackedVector2Array([pos + facing * (radius * 1.45), pos - facing * radius + side * radius * 0.72, pos - facing * radius - side * radius * 0.72])
			draw_colored_polygon(points, base_color)
			draw_line(pos - side * radius, pos + side * radius, accent, 5.0)
			var closed := points.duplicate()
			closed.append(points[0])
			draw_polyline(closed, Color("#101826"), 3.0)
		_:
			draw_circle(pos, radius, base_color)
			draw_circle(pos + facing * radius * 0.52, radius * 0.44, accent)
			draw_line(pos - Vector2(0, radius * 1.25), pos + Vector2(0, radius * 1.25), accent, 4.0)
			draw_arc(pos, radius + 3.0, 0.0, TAU, 32, Color("#101826"), 3.0)

func _draw_health_bar(entity: Dictionary, pos: Vector2) -> void:
	var health: Dictionary = entity.get("health", {})
	var max_health: int = max(1, int(health.get("max", 1)))
	var current: int = int(health.get("current", 0))
	var rect := Rect2(pos, Vector2(52, 6))
	draw_rect(rect, Color("#101826"), true)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * float(current) / float(max_health), rect.size.y)), ArenaTheme.COLOR_GREEN, true)
	draw_rect(rect, Color("#F4F7FB", 0.45), false, 1.0)

func _draw_event(event: Dictionary, camera: Vector2) -> void:
	var event_type := str(event.get("type", ""))
	if event_type == "area_effect":
		var pos := _world_to_screen(_dict_to_vec2(event.get("position", {})), camera)
		draw_circle(pos, float(event.get("radius", 80.0)) * zoom, Color(str(event.get("color", "#FFFFFF")), 0.16))
		draw_arc(pos, float(event.get("radius", 80.0)) * zoom, 0.0, TAU, 48, Color(str(event.get("color", "#FFFFFF"))), 3.0)
	elif event_type == "projectile_cast":
		var source := snapshot.get_entity(int(event.get("source_entity_id", 0)))
		var target := snapshot.get_entity(int(event.get("target_entity_id", 0)))
		if not source.is_empty() and not target.is_empty():
			draw_line(_world_to_screen(_dict_to_vec2(source.get("position", {})), camera), _world_to_screen(_dict_to_vec2(target.get("position", {})), camera), Color(str(event.get("color", "#FFFFFF"))), 3.0)
	elif event_type == "damage_applied":
		var target := snapshot.get_entity(int(event.get("target_entity_id", 0)))
		if not target.is_empty():
			var pos := _world_to_screen(_dict_to_vec2(target.get("position", {})), camera)
			draw_circle(pos, 28.0, Color("#FFFFFF", 0.16))
			draw_string(get_theme_default_font(), pos + Vector2(-12, -28), str(event.get("amount", "")), HORIZONTAL_ALIGNMENT_CENTER, 24.0, 16, ArenaTheme.COLOR_GOLD)

func _local_entity() -> Dictionary:
	if snapshot == null:
		return {}
	for entity in snapshot.entities:
		if str(entity.get("owner_player_id", "")) == local_player_id:
			return entity
	return {}

func _dict_to_vec2(data: Dictionary) -> Vector2:
	return Vector2(float(data.get("x", 0.0)), float(data.get("y", 0.0)))
