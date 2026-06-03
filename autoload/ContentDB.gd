extends Node

var _heroes: Dictionary = {}
var _abilities: Dictionary = {}
var _modes: Dictionary = {}
var _maps: Dictionary = {}
var _bot_profiles: Dictionary = {}
var _load_errors: Array[String] = []
var _loaded := false

func load_all() -> bool:
	var loader := ContentLoader.new()
	var content_path := "res://content"
	if is_inside_tree() and has_node("/root/GameConfig"):
		content_path = get_node("/root/GameConfig").get_content_path()
	var result := loader.load_all(content_path)
	_heroes = result.get("heroes", {})
	_abilities = result.get("abilities", {})
	_modes = result.get("modes", {})
	_maps = result.get("maps", {})
	_bot_profiles = result.get("bot_profiles", {})
	_load_errors = result.get("errors", [])
	_loaded = _load_errors.is_empty()
	return _loaded

func validate_all() -> Array[String]:
	if not _loaded:
		load_all()
	var validator := ContentValidator.new()
	var data := {
		"heroes": _heroes,
		"abilities": _abilities,
		"modes": _modes,
		"maps": _maps,
		"bot_profiles": _bot_profiles,
	}
	var errors := _load_errors.duplicate()
	errors.append_array(validator.validate(data))
	return errors

func get_hero(hero_id: String) -> HeroDef:
	return _heroes.get(hero_id, null)

func get_ability(ability_id: String) -> AbilityDef:
	return _abilities.get(ability_id, null)

func get_mode(mode_id: String) -> ModeDef:
	return _modes.get(mode_id, null)

func get_map(map_id: String) -> MapDef:
	return _maps.get(map_id, null)

func get_bot_profile(profile_id: String) -> BotProfileDef:
	return _bot_profiles.get(profile_id, null)

func get_all_heroes() -> Dictionary:
	return _heroes

func get_all_abilities() -> Dictionary:
	return _abilities

func get_all_modes() -> Dictionary:
	return _modes

func get_all_maps() -> Dictionary:
	return _maps
