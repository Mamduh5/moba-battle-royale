class_name HeroActor
extends Node2D

var entity_data: Dictionary = {}
var local_player_id := ""

func apply_data(data: Dictionary, player_id: String) -> void:
	entity_data = data.duplicate(true)
	local_player_id = player_id
	var pos: Dictionary = entity_data.get("position", {})
	position = Vector2(float(pos.get("x", 0.0)), float(pos.get("y", 0.0)))
	z_index = 20 if str(entity_data.get("owner_player_id", "")) == local_player_id else 10
	queue_redraw()

func _draw() -> void:
	var visual: Dictionary = entity_data.get("visual", {})
	var radius := float(entity_data.get("radius", 16.0))
	var is_local := str(entity_data.get("owner_player_id", "")) == local_player_id
	var alive := bool(entity_data.get("alive", true))
	var primary := Color(str(visual.get("primary_color", "#FFFFFF")))
	var accent := Color(str(visual.get("accent_color", "#111111")))
	if not alive:
		primary.a = 0.35
		accent.a = 0.4
	draw_circle(Vector2(3, 5), radius + 9.0, Color(0.0, 0.0, 0.0, 0.28))
	var team_id := int(entity_data.get("team_id", 0))
	var ring_color := Color(0.25, 0.75, 1.0, 0.95) if team_id == GameConstants.TEAM_A else Color(1.0, 0.35, 0.25, 0.95)
	if team_id == GameConstants.TEAM_NONE:
		ring_color = Color(1.0, 0.35, 0.27, 0.80)
	if is_local:
		draw_arc(Vector2.ZERO, radius + 14.0, 0.0, TAU, 56, Color(1.0, 0.92, 0.24, 1.0), 4.0)
		draw_arc(Vector2.ZERO, radius + 21.0, -0.35, 1.65, 36, Color(0.65, 1.0, 0.88, 0.72), 3.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, -radius - 42),
			Vector2(11, -radius - 26),
			Vector2(0, -radius - 31),
			Vector2(-11, -radius - 26),
		]), Color(1.0, 0.92, 0.24, 0.95))
	else:
		draw_arc(Vector2.ZERO, radius + 7.0, 0.0, TAU, 44, ring_color, 2.4)
	var shape := str(visual.get("body_shape", "circle"))
	match shape:
		"shield":
			var body := PackedVector2Array([Vector2(0, -radius - 9), Vector2(radius + 12, -radius * 0.30), Vector2(radius * 0.82, radius + 7), Vector2(0, radius + 15), Vector2(-radius * 0.82, radius + 7), Vector2(-radius - 12, -radius * 0.30)])
			draw_colored_polygon(body, Color(0.030, 0.040, 0.055, 1.0))
			draw_colored_polygon(_scaled(body, 0.86), primary)
			_draw_closed_polyline(body, accent, 3.0)
			draw_line(Vector2(0, -radius - 4), Vector2(0, radius + 9), accent, 4.0)
			draw_line(Vector2(-radius * 0.55, -2), Vector2(radius * 0.55, -2), Color(1.0, 1.0, 1.0, 0.35), 2.0)
		"blade":
			var blade := PackedVector2Array([Vector2(0, -radius - 14), Vector2(radius + 9, radius * 0.10), Vector2(5, radius + 17), Vector2(-radius - 10, radius * 0.18)])
			draw_colored_polygon(blade, Color(0.025, 0.025, 0.040, 1.0))
			draw_colored_polygon(_scaled(blade, 0.86), primary)
			_draw_closed_polyline(blade, accent, 3.0)
			draw_line(Vector2(-radius * 0.85, radius * 0.58), Vector2(radius * 0.95, -radius * 0.55), accent, 4.0)
			draw_line(Vector2(-radius * 0.70, -radius * 0.2), Vector2(radius * 0.45, radius * 0.55), Color(1.0, 1.0, 1.0, 0.30), 2.0)
		"orb_staff":
			var robe := PackedVector2Array([Vector2(0, -radius - 8), Vector2(radius + 12, radius + 10), Vector2(0, radius + 18), Vector2(-radius - 12, radius + 10)])
			draw_colored_polygon(robe, Color(0.030, 0.035, 0.042, 1.0))
			draw_colored_polygon(_scaled(robe, 0.86), primary)
			_draw_closed_polyline(robe, accent, 2.5)
			draw_circle(Vector2(0, -radius - 10), radius * 0.47, Color(0.030, 0.050, 0.055, 1.0))
			draw_circle(Vector2(0, -radius - 10), radius * 0.35, accent)
			draw_line(Vector2(radius + 3, -radius), Vector2(radius + 12, radius + 14), accent, 4.0)
			draw_arc(Vector2.ZERO, radius + 4, 0.1, TAU - 0.4, 30, Color(accent.r, accent.g, accent.b, 0.42), 2.0)
		_:
			draw_circle(Vector2.ZERO, radius + 3, Color(0.030, 0.035, 0.042, 1.0))
			draw_circle(Vector2.ZERO, radius, primary)
	var facing_data: Dictionary = entity_data.get("facing", {"x": 1.0, "y": 0.0})
	var facing := Vector2(float(facing_data.get("x", 1.0)), float(facing_data.get("y", 0.0))).normalized()
	var nose := facing * (radius + 17.0)
	draw_line(facing * (radius * 0.20), nose, Color(0.0, 0.0, 0.0, 0.65), 6.0)
	draw_line(facing * (radius * 0.20), nose, accent, 3.0)
	var health: Dictionary = entity_data.get("health", {})
	HealthBarPresenter.draw_bar(self, Vector2(-28, -radius - 24), 56, int(health.get("current", 1)), int(health.get("max", 1)), int(health.get("shield", 0)), is_local)

func _scaled(points: PackedVector2Array, scale: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for point in points:
		out.append(point * scale)
	return out

func _draw_closed_polyline(points: PackedVector2Array, color: Color, width: float) -> void:
	var outline := PackedVector2Array(points)
	if not outline.is_empty():
		outline.append(outline[0])
	draw_polyline(outline, color, width)
