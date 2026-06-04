class_name PauseMenu
extends Control

signal resume_requested
signal menu_requested

func _ready() -> void:
	theme = ArenaTheme.create_theme()
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()

func _draw() -> void:
	if not visible:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color("#050912", 0.72), true)

func _build() -> void:
	var box := VBoxContainer.new()
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -170
	box.offset_right = 170
	box.offset_top = -95
	box.offset_bottom = 95
	box.add_theme_constant_override("separation", 12)
	add_child(box)
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", ArenaTheme.COLOR_GOLD)
	box.add_child(title)
	var resume := Button.new()
	resume.text = "Resume"
	resume.pressed.connect(resume_requested.emit)
	box.add_child(resume)
	var menu := Button.new()
	menu.text = "Return To Menu"
	menu.pressed.connect(menu_requested.emit)
	box.add_child(menu)
