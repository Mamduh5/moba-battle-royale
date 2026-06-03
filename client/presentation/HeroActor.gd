class_name HeroActor
extends Node2D

var entity_data: Dictionary = {}
var local_player_id := ""

func apply_data(data: Dictionary, player_id: String) -> void:
	entity_data = data.duplicate(true)
	local_player_id = player_id
	var pos: Dictionary = entity_data.get("position", {})
	position = Vector2(float(pos.get("x", 0.0)), float(pos.get("y", 0.0)))
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
	var team_id := int(entity_data.get("team_id", 0))
	var ring_color := Color(0.25, 0.75, 1.0, 0.95) if team_id == GameConstants.TEAM_A else Color(1.0, 0.35, 0.25, 0.95)
	if team_id == GameConstants.TEAM_NONE:
		ring_color = Color(1.0, 1.0, 1.0, 0.55)
	draw_arc(Vector2.ZERO, radius + (8.0 if is_local else 4.0), 0.0, TAU, 40, Color(1.0, 0.95, 0.35, 1.0) if is_local else ring_color, 3.5 if is_local else 2.0)
	var shape := str(visual.get("body_shape", "circle"))
	match shape:
		"shield":
			draw_colored_polygon([Vector2(0, -radius - 5), Vector2(radius + 8, -radius * 0.25), Vector2(radius * 0.7, radius + 5), Vector2(0, radius + 10), Vector2(-radius * 0.7, radius + 5), Vector2(-radius - 8, -radius * 0.25)], primary)
			draw_line(Vector2(0, -radius - 3), Vector2(0, radius + 6), accent, 3.0)
		"blade":
			draw_colored_polygon([Vector2(0, -radius - 9), Vector2(radius + 5, radius * 0.2), Vector2(4, radius + 12), Vector2(-radius - 5, radius * 0.2)], primary)
			draw_line(Vector2(-radius * 0.7, radius * 0.5), Vector2(radius * 0.8, -radius * 0.45), accent, 3.0)
		"orb_staff":
			draw_circle(Vector2.ZERO, radius, primary)
			draw_circle(Vector2(0, -radius - 7), radius * 0.38, accent)
			draw_line(Vector2(radius + 2, -radius), Vector2(radius + 8, radius + 9), accent, 3.0)
		_:
			draw_circle(Vector2.ZERO, radius, primary)
	var facing_data: Dictionary = entity_data.get("facing", {"x": 1.0, "y": 0.0})
	var facing := Vector2(float(facing_data.get("x", 1.0)), float(facing_data.get("y", 0.0))).normalized()
	draw_line(Vector2.ZERO, facing * (radius + 12.0), accent, 3.0)
	var health: Dictionary = entity_data.get("health", {})
	HealthBarPresenter.draw_bar(self, Vector2(-22, -radius - 20), 44, int(health.get("current", 1)), int(health.get("max", 1)), int(health.get("shield", 0)), is_local)
