class_name ValidateContentCommand
extends RefCounted

func run(_options: Dictionary = {}) -> int:
	var loader := ContentLoader.new()
	var content := loader.load_all_content("res://content")
	var errors := ContentValidator.new().validate_loaded_content(content)
	if not errors.is_empty():
		print(JSON.stringify({"cmd": "validate-content", "status": "fail", "errors": errors}))
		return 3
	print(JSON.stringify({
		"cmd": "validate-content",
		"status": "pass",
		"heroes": content.get("heroes", []).size(),
		"abilities": content.get("abilities", []).size(),
		"modes": content.get("modes", []).size(),
		"maps": content.get("maps", []).size(),
		"bots": content.get("bots", []).size(),
	}))
	return 0
