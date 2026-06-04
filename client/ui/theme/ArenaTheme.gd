class_name ArenaTheme
extends RefCounted

const COLOR_BG := Color("#101826")
const COLOR_BG_2 := Color("#172235")
const COLOR_PANEL := Color("#223149")
const COLOR_PANEL_DARK := Color("#141D2C")
const COLOR_TEXT := Color("#F4F7FB")
const COLOR_MUTED := Color("#AAB7C8")
const COLOR_BLUE := Color("#30D1C8")
const COLOR_RED := Color("#FF4D8D")
const COLOR_GOLD := Color("#F8D85D")
const COLOR_GREEN := Color("#72FF7D")
const COLOR_PURPLE := Color("#7C6DFF")

static func create_theme() -> Theme:
	var theme := Theme.new()
	theme.set_stylebox("normal", "Button", button_style(COLOR_PANEL, COLOR_BLUE, 1.0))
	theme.set_stylebox("hover", "Button", button_style(Color("#2B3F5D"), COLOR_GOLD, 1.0))
	theme.set_stylebox("pressed", "Button", button_style(Color("#182235"), COLOR_BLUE, 1.0))
	theme.set_stylebox("focus", "Button", button_style(Color("#2B3F5D"), COLOR_GREEN, 1.0))
	theme.set_color("font_color", "Button", COLOR_TEXT)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", COLOR_GOLD)
	theme.set_font_size("font_size", "Button", 18)
	theme.set_stylebox("normal", "PanelContainer", panel_style(COLOR_PANEL_DARK, COLOR_BLUE, 0.55))
	theme.set_color("font_color", "Label", COLOR_TEXT)
	theme.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.45))
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 2)
	theme.set_font_size("font_size", "Label", 18)
	theme.set_color("font_color", "LineEdit", COLOR_TEXT)
	theme.set_stylebox("normal", "LineEdit", panel_style(Color("#162336"), COLOR_BLUE, 0.55))
	theme.set_stylebox("focus", "LineEdit", panel_style(Color("#1D314A"), COLOR_GOLD, 0.8))
	return theme

static func button_style(fill: Color, border: Color, alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill.r, fill.g, fill.b, alpha)
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = 5
	return style

static func panel_style(fill: Color, border: Color, alpha: float = 1.0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill.r, fill.g, fill.b, alpha)
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	style.shadow_color = Color(0, 0, 0, 0.32)
	style.shadow_size = 6
	return style

static func team_color(team_id: int) -> Color:
	if team_id == GameConstants.TEAM_BLUE:
		return COLOR_BLUE
	if team_id == GameConstants.TEAM_RED:
		return COLOR_RED
	return COLOR_GOLD

static func color_from_hex(hex: String, fallback: Color = Color.WHITE) -> Color:
	if hex == "":
		return fallback
	return Color(hex)
