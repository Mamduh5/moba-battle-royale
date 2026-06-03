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
	draw_circle(Vector2.ZERO, float(entity_data.get("radius", 6.0)) + 4.0, Color(color.r, color.g, color.b, 0.20))
	draw_circle(Vector2.ZERO, float(entity_data.get("radius", 6.0)), color)
