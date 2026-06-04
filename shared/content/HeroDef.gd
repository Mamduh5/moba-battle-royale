class_name HeroDef
extends RefCounted

var id := ""
var display_name := ""
var role := ""
var max_health := 1
var move_speed := 1.0
var primary_color := "#FFFFFF"
var accent_color := "#FFFFFF"
var silhouette := "shield"
var abilities: Array[Dictionary] = []

static func from_dict(data: Dictionary) -> HeroDef:
	var hero := HeroDef.new()
	hero.id = str(data.get("id", ""))
	hero.display_name = str(data.get("display_name", hero.id))
	hero.role = str(data.get("role", ""))
	hero.max_health = int(data.get("max_health", 1))
	hero.move_speed = float(data.get("move_speed", 1.0))
	hero.primary_color = str(data.get("primary_color", "#FFFFFF"))
	hero.accent_color = str(data.get("accent_color", "#FFFFFF"))
	hero.silhouette = str(data.get("silhouette", "shield"))
	hero.abilities.clear()
	for entry in data.get("abilities", []):
		if typeof(entry) == TYPE_DICTIONARY:
			hero.abilities.append(entry.duplicate(true))
	return hero

func get_ability_id_for_slot(slot: String) -> String:
	for entry in abilities:
		if str(entry.get("slot", "")) == slot:
			return str(entry.get("ability_id", ""))
	return ""

func get_ability_map() -> Dictionary:
	var out := {}
	for entry in abilities:
		out[str(entry.get("slot", ""))] = str(entry.get("ability_id", ""))
	return out
