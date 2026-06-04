extends Node

var _loaded := false
var _heroes: Dictionary = {}
var _abilities: Dictionary = {}
var _modes: Dictionary = {}
var _maps: Dictionary = {}
var _bot_profiles: Dictionary = {}
var _last_errors: Array[String] = []

func _ready() -> void:
	load_all()

func load_all() -> bool:
	var loader := ContentLoader.new()
	var loaded := loader.load_all_content("res://content")
	var validator := ContentValidator.new()
	_last_errors = validator.validate_loaded_content(loaded)
	if not _last_errors.is_empty():
		_loaded = false
		return false
	_heroes.clear()
	_abilities.clear()
	_modes.clear()
	_maps.clear()
	_bot_profiles.clear()
	for data in loaded.get("heroes", []):
		var hero := HeroDef.from_dict(data)
		_heroes[hero.id] = hero
	for data in loaded.get("abilities", []):
		var ability := AbilityDef.from_dict(data)
		_abilities[ability.id] = ability
	for data in loaded.get("modes", []):
		var mode := ModeDef.from_dict(data)
		_modes[mode.id] = mode
	for data in loaded.get("maps", []):
		var map_def := MapDef.from_dict(data)
		_maps[map_def.id] = map_def
	for data in loaded.get("bots", []):
		var profile := BotProfileDef.from_dict(data)
		_bot_profiles[profile.id] = profile
	_loaded = true
	return true

func validate_all() -> Array[String]:
	if not _loaded:
		load_all()
	return _last_errors.duplicate()

func is_loaded() -> bool:
	return _loaded

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

func get_all_heroes() -> Array:
	return _heroes.values()

func get_all_abilities() -> Array:
	return _abilities.values()

func get_all_modes() -> Array:
	return _modes.values()

func get_all_maps() -> Array:
	return _maps.values()

func get_all_bot_profiles() -> Array:
	return _bot_profiles.values()

func get_first_bot_profile() -> BotProfileDef:
	if _bot_profiles.has("bot_normal"):
		return _bot_profiles["bot_normal"]
	for profile in _bot_profiles.values():
		return profile
	return null
