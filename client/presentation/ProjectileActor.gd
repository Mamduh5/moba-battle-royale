class_name ProjectileActor
extends Node2D

var entity_data: Dictionary = {}

func apply_data(data: Dictionary) -> void:
	entity_data = data.duplicate(true)
	var pos: Dictionary = entity_data.get("position", {})
	position = Vector2(float(pos.get("x", 0.0)), float(pos.get("y", 0.0)))
	queue_redraw()

func _draw() -> void:
	var visual: Dictionary = entity_data.get("visual", {})
	var color := Color(str(visual.get("primary_color", "#FFFFFF")))
	var radius := float(entity_data.get("radius", 6.0))
	var velocity_data: Dictionary = entity_data.get("velocity", {})
	var velocity := Vector2(float(velocity_data.get("x", 0.0)), float(velocity_data.get("y", 0.0)))
	var dir := velocity.normalized() if velocity.length_squared() > 0.001 else Vector2.RIGHT
	var tail := -dir * (radius * 4.6)
	draw_line(tail, -dir * radius, Color(color.r, color.g, color.b, 0.30), radius * 1.3)
	draw_line(tail * 0.72, dir * radius * 0.35, Color(color.r, color.g, color.b, 0.62), radius * 0.75)
	draw_circle(Vector2.ZERO, radius + 5.0, Color(color.r, color.g, color.b, 0.18))
	draw_circle(Vector2.ZERO, radius + 1.5, Color(0.02, 0.025, 0.030, 0.9))
	draw_circle(Vector2.ZERO, radius, color)
	draw_circle(dir * radius * 0.25, radius * 0.42, Color(1.0, 1.0, 1.0, 0.72))
