class_name AbilityDef
extends RefCounted

var id := ""
var display_name := ""
var slot := ""
var family := ""
var cast_kind := ""
var damage := 0
var range := 0.0
var radius := 0.0
var shield := 0
var cooldown_sec := 0.0
var execute_bonus_threshold := 0.0
var vfx_color := "#FFFFFF"
var icon := "bolt"

static func from_dict(data: Dictionary) -> AbilityDef:
	var ability := AbilityDef.new()
	ability.id = str(data.get("id", ""))
	ability.display_name = str(data.get("display_name", ability.id))
	ability.slot = str(data.get("slot", ""))
	ability.family = str(data.get("family", ""))
	ability.cast_kind = str(data.get("cast_kind", "instant"))
	ability.damage = int(data.get("damage", 0))
	ability.range = float(data.get("range", 0.0))
	ability.radius = float(data.get("radius", 0.0))
	ability.shield = int(data.get("shield", 0))
	ability.cooldown_sec = float(data.get("cooldown_sec", 0.0))
	ability.execute_bonus_threshold = float(data.get("execute_bonus_threshold", 0.0))
	ability.vfx_color = str(data.get("vfx_color", "#FFFFFF"))
	ability.icon = str(data.get("icon", "bolt"))
	return ability
