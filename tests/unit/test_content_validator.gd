extends RefCounted

func run() -> Array[String]:
	var loader := ContentLoader.new()
	return ContentValidator.new().validate_loaded_content(loader.load_all_content("res://content"))
