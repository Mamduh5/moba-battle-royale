class_name ObjectiveActor
extends Node2D

var radius := 80.0

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color("#F8D85D", 0.08))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, ArenaTheme.COLOR_GOLD, 3.0)
