class_name ContentValidator
extends RefCounted

func validate(data: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var heroes: Dictionary = data.get("heroes", {})
	var abilities: Dictionary = data.get("abilities", {})
	var modes: Dictionary = data.get("modes", {})
	var maps: Dictionary = data.get("maps", {})
	var bot_profiles: Dictionary = data.get("bot_profiles", {})
	_validate_counts(heroes, abilities, modes, maps, bot_profiles, errors)
	_validate_heroes(heroes, abilities, errors)
	_validate_abilities(abilities, errors)
	_validate_modes(modes, maps, bot_profiles, errors)
	_validate_maps(maps, errors)
	_validate_bots(bot_profiles, heroes, errors)
	return errors

func _validate_counts(heroes: Dictionary, abilities: Dictionary, modes: Dictionary, maps: Dictionary, bot_profiles: Dictionary, errors: Array[String]) -> void:
	if heroes.size() < 3:
		errors.append("At least 3 heroes are required.")
	if abilities.size() < 9:
		errors.append("At least 9 abilities are required.")
	if not modes.has(GameConstants.MODE_TEAM_ARENA):
		errors.append("Missing required mode: %s" % GameConstants.MODE_TEAM_ARENA)
	if not modes.has(GameConstants.MODE_DEATHMATCH):
		errors.append("Missing required mode: %s" % GameConstants.MODE_DEATHMATCH)
	if maps.is_empty():
		errors.append("At least one map is required.")
	if bot_profiles.is_empty():
		errors.append("At least one bot profile is required.")

func _validate_heroes(heroes: Dictionary, abilities: Dictionary, errors: Array[String]) -> void:
	for hero_id in heroes.keys():
		var hero: HeroDef = heroes[hero_id]
		if hero.display_name == "":
			errors.append("Hero %s is missing display_name." % hero_id)
		if hero.get_max_health() <= 0:
			errors.append("Hero %s max_health must be positive." % hero_id)
		var required_slots := [GameConstants.SLOT_BASIC, GameConstants.SLOT_ABILITY_1, GameConstants.SLOT_ULTIMATE]
		for slot in required_slots:
			var ability_id := str(hero.ability_slots.get(slot, ""))
			if ability_id == "":
				errors.append("Hero %s is missing ability slot %s." % [hero_id, slot])
			elif not abilities.has(ability_id):
				errors.append("Hero %s references missing ability %s." % [hero_id, ability_id])

func _validate_abilities(abilities: Dictionary, errors: Array[String]) -> void:
	for ability_id in abilities.keys():
		var ability: AbilityDef = abilities[ability_id]
		if ability.display_name == "":
			errors.append("Ability %s is missing display_name." % ability_id)
		if ability.slot == "":
			errors.append("Ability %s is missing slot." % ability_id)
		if ability.cooldown_sec < 0.0:
			errors.append("Ability %s cooldown cannot be negative." % ability_id)
		if ability.range < 0.0 or ability.radius < 0.0:
			errors.append("Ability %s range/radius cannot be negative." % ability_id)
		if ability.effect_type == "":
			errors.append("Ability %s is missing effect_type." % ability_id)

func _validate_modes(modes: Dictionary, maps: Dictionary, bot_profiles: Dictionary, errors: Array[String]) -> void:
	for mode_id in modes.keys():
		var mode: ModeDef = modes[mode_id]
		if not maps.has(mode.map_id):
			errors.append("Mode %s references missing map %s." % [mode_id, mode.map_id])
		if not bot_profiles.has(mode.bot_profile_id):
			errors.append("Mode %s references missing bot profile %s." % [mode_id, mode.bot_profile_id])
		if mode.max_participants <= 0:
			errors.append("Mode %s max_participants must be positive." % mode_id)
		if mode.score_limit <= 0 and mode.duration_sec <= 0:
			errors.append("Mode %s needs score_limit or duration_sec." % mode_id)
		if mode_id == GameConstants.MODE_TEAM_ARENA:
			if not mode.team_based or mode.max_participants != 6 or mode.team_size != 3:
				errors.append("3v3 Team Arena must be team-based with 6 participants and team size 3.")
		if mode_id == GameConstants.MODE_DEATHMATCH:
			if mode.team_based or mode.max_participants != 25:
				errors.append("25 Player Deathmatch must be free-for-all with 25 participants.")

func _validate_maps(maps: Dictionary, errors: Array[String]) -> void:
	for map_id in maps.keys():
		var map_def: MapDef = maps[map_id]
		var bounds := map_def.get_bounds_rect()
		if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
			errors.append("Map %s has invalid bounds." % map_id)
		if map_def.spawn_points.size() < 6:
			errors.append("Map %s needs at least 6 spawn points." % map_id)
		var ffa_count := 0
		for spawn in map_def.spawn_points:
			if int(spawn.get("team_id", 0)) == 0:
				ffa_count += 1
		if ffa_count < 25:
			errors.append("Map %s needs at least 25 free-for-all spawn points." % map_id)

func _validate_bots(bot_profiles: Dictionary, heroes: Dictionary, errors: Array[String]) -> void:
	for profile_id in bot_profiles.keys():
		var profile: BotProfileDef = bot_profiles[profile_id]
		if profile.hero_pool.is_empty():
			errors.append("Bot profile %s needs a hero_pool." % profile_id)
		for hero_id in profile.hero_pool:
			if not heroes.has(str(hero_id)):
				errors.append("Bot profile %s references missing hero %s." % [profile_id, str(hero_id)])
