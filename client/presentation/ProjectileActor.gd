class_name ProjectileActor
extends Node2D

var color := ArenaTheme.COLOR_GOLD

func _draw() -> void:
	draw_line(Vector2(-18, 0), Vector2(18, 0), color, 4.0)
	draw_circle(Vector2(18, 0), 5.0, color)
