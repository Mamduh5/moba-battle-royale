class_name ContentValidator
extends RefCounted

func validate_loaded_content(content: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var heroes: Array = content.get("heroes", [])
	var abilities: Array = content.get("abilities", [])
	var modes: Array = content.get("modes", [])
	var maps: Array = content.get("maps", [])
	var bots: Array = content.get("bots", [])
	_validate_load_errors("heroes", heroes, errors)
	_validate_load_errors("abilities", abilities, errors)
	_validate_load_errors("modes", modes, errors)
	_validate_load_errors("maps", maps, errors)
	_validate_load_errors("bots", bots, errors)
	var hero_ids := _collect_ids("hero", heroes, errors)
	var ability_ids := _collect_ids("ability", abilities, errors)
	var mode_ids := _collect_ids("mode", modes, errors)
	var map_ids := _collect_ids("map", maps, errors)
	var bot_ids := _collect_ids("bot", bots, errors)
	if hero_ids.size() < 3:
		errors.append("at least 3 heroes are required")
	if ability_ids.size() < 9:
		errors.append("at least 9 abilities are required")
	if not mode_ids.has("3v3_team_arena"):
		errors.append("mode 3v3_team_arena is required")
	if not mode_ids.has("25_player_deathmatch"):
		errors.append("mode 25_player_deathmatch is required")
	if map_ids.is_empty():
		errors.append("at least one map is required")
	if bot_ids.is_empty():
		errors.append("at least one bot profile is required")
	for hero in heroes:
		if hero.has("__load_error"):
			continue
		var slots := {}
		for ability_entry in hero.get("abilities", []):
			var slot := str(ability_entry.get("slot", ""))
			var ability_id := str(ability_entry.get("ability_id", ""))
			if slot == "":
				errors.append("hero %s has an ability with missing slot" % str(hero.get("id", "")))
			if slots.has(slot):
				errors.append("hero %s duplicates ability slot %s" % [str(hero.get("id", "")), slot])
			slots[slot] = true
			if not ability_ids.has(ability_id):
				errors.append("hero %s references missing ability %s" % [str(hero.get("id", "")), ability_id])
		for required_slot in [GameConstants.SLOT_BASIC, GameConstants.SLOT_ABILITY_1, GameConstants.SLOT_ULTIMATE]:
			if not slots.has(required_slot):
				errors.append("hero %s is missing slot %s" % [str(hero.get("id", "")), required_slot])
	for mode in modes:
		if mode.has("__load_error"):
			continue
		var mode_id := str(mode.get("id", ""))
		var map_id := str(mode.get("map_id", ""))
		if not map_ids.has(map_id):
			errors.append("mode %s references missing map %s" % [mode_id, map_id])
		if int(mode.get("max_participants", 0)) <= 0:
			errors.append("mode %s must have max_participants" % mode_id)
		if mode_id == "25_player_deathmatch" and bool(mode.get("teams_enabled", false)):
			errors.append("deathmatch must not enable teams")
		if mode_id == "25_player_deathmatch" and int(mode.get("max_participants", 0)) != 25:
			errors.append("deathmatch must support 25 participants")
	for bot in bots:
		if bot.has("__load_error"):
			continue
		for hero_id in bot.get("hero_rotation", []):
			if not hero_ids.has(str(hero_id)):
				errors.append("bot profile %s references missing hero %s" % [str(bot.get("id", "")), str(hero_id)])
	return errors

func _validate_load_errors(label: String, items: Array, errors: Array[String]) -> void:
	for item in items:
		if item.has("__load_error"):
			errors.append("%s load error at %s: %s" % [label, str(item.get("path", "")), str(item.get("__load_error", ""))])

func _collect_ids(label: String, items: Array, errors: Array[String]) -> Dictionary:
	var ids := {}
	for item in items:
		if item.has("__load_error"):
			continue
		var id := str(item.get("id", ""))
		if id == "":
			errors.append("%s missing id" % label)
			continue
		if ids.has(id):
			errors.append("duplicate %s id %s" % [label, id])
		ids[id] = true
	return ids
