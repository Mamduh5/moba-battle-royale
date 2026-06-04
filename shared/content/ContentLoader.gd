class_name ContentLoader
extends RefCounted

func load_all_content(root_path: String = "res://content") -> Dictionary:
	return {
		"heroes": _load_json_dir(root_path.path_join("heroes")),
		"abilities": _load_json_dir(root_path.path_join("abilities")),
		"modes": _load_json_dir(root_path.path_join("modes")),
		"maps": _load_json_dir(root_path.path_join("maps")),
		"bots": _load_json_dir(root_path.path_join("bots")),
	}

func _load_json_dir(path: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var dir := DirAccess.open(path)
	if dir == null:
		result.append({"__load_error": "missing_directory", "path": path})
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var full_path := path.path_join(file_name)
			var file := FileAccess.open(full_path, FileAccess.READ)
			if file == null:
				result.append({"__load_error": "cannot_open", "path": full_path})
			else:
				var parsed = JSON.parse_string(file.get_as_text())
				if typeof(parsed) == TYPE_DICTIONARY:
					result.append(parsed)
				else:
					result.append({"__load_error": "invalid_json", "path": full_path})
		file_name = dir.get_next()
	dir.list_dir_end()
	return result
