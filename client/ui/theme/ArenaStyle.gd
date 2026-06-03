class_name ArenaStyle
extends RefCounted

const BG_DEEP := Color(0.025, 0.055, 0.065)
const BG_FIELD := Color(0.055, 0.135, 0.150)
const PANEL := Color(0.065, 0.095, 0.105, 0.92)
const PANEL_LIGHT := Color(0.105, 0.155, 0.165, 0.95)
const PANEL_DARK := Color(0.030, 0.045, 0.052, 0.96)
const LINE := Color(0.300, 0.930, 0.880, 0.72)
const LINE_SOFT := Color(0.300, 0.930, 0.880, 0.22)
const TEXT := Color(0.930, 0.975, 0.955)
const TEXT_MUTED := Color(0.610, 0.735, 0.730)
const GOLD := Color(1.000, 0.765, 0.275)
const CORAL := Color(1.000, 0.335, 0.270)
const BLUE := Color(0.230, 0.630, 1.000)
const GREEN := Color(0.200, 0.920, 0.600)
const PURPLE := Color(0.665, 0.270, 1.000)

static func panel(fill: Color = PANEL, border: Color = LINE_SOFT, radius: int = 8, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	style.shadow_size = 8
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	return style

static func button_style(fill: Color, border: Color, radius: int = 8) -> StyleBoxFlat:
	var style := panel(fill, border, radius, 1)
	style.shadow_size = 5
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

static func style_button(button: BaseButton, variant: String = "primary", min_size: Vector2 = Vector2(180, 44)) -> void:
	button.custom_minimum_size = min_size
	button.focus_mode = Control.FOCUS_ALL
	var normal := button_style(Color(0.080, 0.130, 0.145, 0.96), Color(0.230, 0.700, 0.720, 0.55))
	var hover := button_style(Color(0.110, 0.190, 0.205, 0.98), Color(0.420, 1.000, 0.920, 0.88))
	var pressed := button_style(Color(0.045, 0.100, 0.115, 0.98), GOLD)
	if variant == "primary":
		normal = button_style(Color(0.130, 0.215, 0.235, 0.98), Color(0.500, 1.000, 0.920, 0.72))
		hover = button_style(Color(0.175, 0.295, 0.300, 0.98), Color(0.700, 1.000, 0.920, 0.95))
		pressed = button_style(Color(0.080, 0.160, 0.170, 0.98), GOLD)
	elif variant == "danger":
		normal = button_style(Color(0.160, 0.080, 0.080, 0.96), Color(1.000, 0.390, 0.330, 0.75))
		hover = button_style(Color(0.240, 0.105, 0.095, 0.98), Color(1.000, 0.610, 0.500, 0.95))
		pressed = button_style(Color(0.110, 0.050, 0.045, 0.98), GOLD)
	elif variant == "selected":
		normal = button_style(Color(0.210, 0.170, 0.080, 0.98), GOLD)
		hover = button_style(Color(0.255, 0.215, 0.095, 0.98), Color(1.000, 0.890, 0.430, 0.95))
		pressed = button_style(Color(0.155, 0.125, 0.055, 0.98), GOLD)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", button_style(Color(0.095, 0.165, 0.178, 0.55), Color(0.900, 1.000, 0.700, 0.88)))
	button.add_theme_stylebox_override("disabled", button_style(Color(0.055, 0.070, 0.075, 0.88), Color(0.200, 0.245, 0.250, 0.70)))
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", GOLD)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color(0.450, 0.500, 0.500))
	button.add_theme_font_size_override("font_size", 16)

static func style_label(label: Label, size: int = 18, color: Color = TEXT, shadow: bool = true) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	if shadow:
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)

static func style_panel_container(panel_container: PanelContainer, fill: Color = PANEL, border: Color = LINE_SOFT) -> void:
	panel_container.add_theme_stylebox_override("panel", panel(fill, border))

static func style_line_edit(line_edit: LineEdit) -> void:
	line_edit.add_theme_stylebox_override("normal", panel(Color(0.035, 0.060, 0.068, 0.95), Color(0.250, 0.700, 0.720, 0.50), 6))
	line_edit.add_theme_stylebox_override("focus", panel(Color(0.055, 0.095, 0.105, 0.98), GOLD, 6, 2))
	line_edit.add_theme_color_override("font_color", TEXT)
	line_edit.add_theme_color_override("caret_color", GOLD)
	line_edit.add_theme_font_size_override("font_size", 16)

static func style_option(option_button: OptionButton) -> void:
	style_button(option_button, "secondary", Vector2(320, 44))

static func add_section_label(parent: Node, text: String) -> Label:
	var label := Label.new()
	label.text = text.to_upper()
	style_label(label, 13, TEXT_MUTED)
	parent.add_child(label)
	return label
