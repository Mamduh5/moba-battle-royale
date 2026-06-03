class_name ContentLoader
extends RefCounted

func load_all(root_path: String = "res://content") -> Dictionary:
	var errors: Array[String] = []
	var heroes := _load_defs(root_path + "/heroes", "hero", errors)
	var abilities := _load_defs(root_path + "/abilities", "ability", errors)
	var modes := _load_defs(root_path + "/modes", "mode", errors)
	var maps := _load_defs(root_path + "/maps", "map", errors)
	var bot_profiles := _load_defs(root_path + "/bots", "bot_profile", errors)
	return {
		"heroes": heroes,
		"abilities": abilities,
		"modes": modes,
		"maps": maps,
		"bot_profiles": bot_profiles,
		"errors": errors,
	}

func _load_defs(folder_path: String, kind: String, errors: Array[String]) -> Dictionary:
	var defs: Dictionary = {}
	var dir := DirAccess.open(folder_path)
	if dir == null:
		errors.append("Missing content folder: %s" % folder_path)
		return defs
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var full_path := folder_path + "/" + file_name
			var text := FileAccess.get_file_as_string(full_path)
			var parsed = JSON.parse_string(text)
			if typeof(parsed) != TYPE_DICTIONARY:
				errors.append("Invalid JSON dictionary: %s" % full_path)
			else:
				var id := str(parsed.get("id", ""))
				if id == "":
					errors.append("Missing id in %s" % full_path)
				elif defs.has(id):
					errors.append("Duplicate %s id: %s" % [kind, id])
				else:
					defs[id] = _make_def(kind, parsed)
		file_name = dir.get_next()
	dir.list_dir_end()
	return defs

func _make_def(kind: String, data: Dictionary) -> RefCounted:
	match kind:
		"hero":
			return HeroDef.from_dict(data)
		"ability":
			return AbilityDef.from_dict(data)
		"mode":
			return ModeDef.from_dict(data)
		"map":
			return MapDef.from_dict(data)
		"bot_profile":
			return BotProfileDef.from_dict(data)
	return RefCounted.new()
