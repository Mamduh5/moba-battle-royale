class_name AbilityDef
extends RefCounted

var id := ""
var display_name := ""
var slot := ""
var icon_symbol := ""
var effect_type := ""
var damage := 0.0
var cooldown_sec := 0.0
var range := 0.0
var radius := 0.0
var projectile_speed := 0.0
var lifetime_sec := 0.0
var dash_distance := 0.0
var shield := 0.0
var vfx_color := "#FFFFFF"
var raw: Dictionary = {}

static func from_dict(data: Dictionary) -> AbilityDef:
	var def := AbilityDef.new()
	def.raw = data.duplicate(true)
	def.id = str(data.get("id", ""))
	def.display_name = str(data.get("display_name", def.id))
	def.slot = str(data.get("slot", ""))
	def.icon_symbol = str(data.get("icon_symbol", "bolt"))
	def.effect_type = str(data.get("effect_type", "instant_arc"))
	def.damage = float(data.get("damage", 0.0))
	def.cooldown_sec = float(data.get("cooldown_sec", 0.0))
	def.range = float(data.get("range", 0.0))
	def.radius = float(data.get("radius", 0.0))
	def.projectile_speed = float(data.get("projectile_speed", 0.0))
	def.lifetime_sec = float(data.get("lifetime_sec", 0.0))
	def.dash_distance = float(data.get("dash_distance", data.get("range", 0.0)))
	def.shield = float(data.get("shield", 0.0))
	def.vfx_color = str(data.get("vfx_color", "#FFFFFF"))
	return def
