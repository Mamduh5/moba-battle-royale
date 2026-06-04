class_name MainMenu
extends Control

signal quick_start_requested
signal mode_select_requested
signal host_requested
signal join_requested(room_code: String)

var _room_code: LineEdit = null

func _ready() -> void:
	theme = ArenaTheme.create_theme()
	_build()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), ArenaTheme.COLOR_BG, true)
	var center := size * 0.5
	for i in range(9):
		var radius := 90.0 + i * 48.0
		draw_arc(center, radius, 0.0, TAU, 96, Color("#30D1C8", 0.06), 2.0)
	draw_circle(center + Vector2(-320, -130), 90, Color("#FF4D8D", 0.10))
	draw_circle(center + Vector2(330, 122), 120, Color("#F8D85D", 0.08))

func _build() -> void:
	var root := VBoxContainer.new()
	root.anchor_left = 0.5
	root.anchor_right = 0.5
	root.anchor_top = 0.5
	root.anchor_bottom = 0.5
	root.offset_left = -285
	root.offset_right = 285
	root.offset_top = -250
	root.offset_bottom = 250
	root.add_theme_constant_override("separation", 14)
	add_child(root)
	var title := Label.new()
	title.text = "ARENA ROYALE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 54)
	title.add_theme_color_override("font_color", ArenaTheme.COLOR_GOLD)
	root.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Server-authoritative hero arena"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", ArenaTheme.COLOR_MUTED)
	root.add_child(subtitle)
	root.add_child(_button("Quick 3v3 Battle", quick_start_requested.emit))
	root.add_child(_button("Choose Mode", mode_select_requested.emit))
	root.add_child(_button("Host Match With Bots", host_requested.emit))
	_room_code = LineEdit.new()
	_room_code.placeholder_text = "Room code or LAN address"
	_room_code.text = "LOCAL-ARENA"
	root.add_child(_room_code)
	root.add_child(_button("Join Friend Match", func() -> void: join_requested.emit(_room_code.text)))
	var footer := Label.new()
	footer.text = "WASD move  |  Mouse aim/fire  |  E skill  |  R ultimate"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", ArenaTheme.COLOR_MUTED)
	root.add_child(footer)

func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 50)
	button.pressed.connect(callback)
	return button
