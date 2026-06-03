class_name MainMenuScreen
extends Control

signal quick_start_pressed
signal mode_select_pressed

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.anchor_left = 0.08
	box.anchor_top = 0.12
	box.anchor_right = 0.48
	box.anchor_bottom = 0.86
	box.add_theme_constant_override("separation", 16)
	add_child(box)
	var title := Label.new()
	title.text = "Arena Royale"
	title.add_theme_font_size_override("font_size", 54)
	box.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Choose a hero, fill the arena with bots, and fight to the result screen."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(subtitle)
	var quick := Button.new()
	quick.text = "Quick Start Team Arena"
	quick.custom_minimum_size = Vector2(300, 46)
	quick.pressed.connect(func() -> void: quick_start_pressed.emit())
	box.add_child(quick)
	var modes := Button.new()
	modes.text = "Mode Select"
	modes.custom_minimum_size = Vector2(300, 46)
	modes.pressed.connect(func() -> void: mode_select_pressed.emit())
	box.add_child(modes)
