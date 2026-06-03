class_name ValidateContentCommand
extends RefCounted

func run(_args: Dictionary, content_db: Object) -> int:
	content_db.load_all()
	var errors: Array[String] = content_db.validate_all()
	if not errors.is_empty():
		for error in errors:
			printerr("content_error: %s" % error)
		return ProtocolConstants.EXIT_CONTENT_VALIDATION_FAILURE
	print("validate-content: ok heroes=%d abilities=%d modes=%d maps=%d" % [
		content_db.get_all_heroes().size(),
		content_db.get_all_abilities().size(),
		content_db.get_all_modes().size(),
		content_db.get_all_maps().size(),
	])
	return ProtocolConstants.EXIT_SUCCESS
