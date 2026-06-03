extends SceneTree

const ContentDBScript := preload("res://autoload/ContentDB.gd")
const ProtocolConstantsScript := preload("res://shared/constants/ProtocolConstants.gd")
const ValidateContentCommandScript := preload("res://tools/cli/ValidateContentCommand.gd")
const ProtocolCheckCommandScript := preload("res://tools/cli/ProtocolCheckCommand.gd")
const BotSoakCommandScript := preload("res://tools/cli/BotSoakCommand.gd")
const RunTestsCommandScript := preload("res://tools/cli/RunTestsCommand.gd")
const ServerSmokeCommandScript := preload("res://tools/cli/ServerSmokeCommand.gd")
const VisualSmokeCommandScript := preload("res://tools/cli/VisualSmokeCommand.gd")
const ExportServerCommandScript := preload("res://tools/cli/ExportServerCommand.gd")

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var parsed := _parse_args(args)
	var exit_code := _dispatch(parsed)
	quit(exit_code)

func _parse_args(args: PackedStringArray) -> Dictionary:
	var parsed: Dictionary = {"cmd": ""}
	var i := 0
	while i < args.size():
		var arg := args[i]
		if arg == "--cmd" and i + 1 < args.size():
			parsed["cmd"] = args[i + 1]
			i += 2
		elif arg.begins_with("--"):
			var key := arg.substr(2)
			if i + 1 < args.size() and not String(args[i + 1]).begins_with("--"):
				parsed[key] = args[i + 1]
				i += 2
			else:
				parsed[key] = true
				i += 1
		elif str(parsed.get("cmd", "")) == "":
			parsed["cmd"] = arg
			i += 1
		else:
			i += 1
	return parsed

func _dispatch(parsed: Dictionary) -> int:
	var command := str(parsed.get("cmd", ""))
	var content_db: Object = root.get_node_or_null("ContentDB")
	if content_db == null:
		content_db = ContentDBScript.new()
		content_db.name = "ContentDB"
		root.add_child(content_db)
	match command:
		"validate-content":
			return ValidateContentCommandScript.new().run(parsed, content_db)
		"protocol-check":
			return ProtocolCheckCommandScript.new().run(parsed)
		"bot-soak":
			return BotSoakCommandScript.new().run(parsed, content_db)
		"run-tests":
			return RunTestsCommandScript.new().run(parsed, content_db)
		"server-smoke":
			return ServerSmokeCommandScript.new().run(parsed, content_db)
		"visual-smoke":
			return VisualSmokeCommandScript.new().run(parsed, content_db)
		"export-server":
			return ExportServerCommandScript.new().run(parsed)
		_:
			printerr("Unknown command. Use --cmd validate-content|protocol-check|bot-soak|run-tests|server-smoke|visual-smoke|export-server")
			return ProtocolConstantsScript.EXIT_INVALID_ARGUMENTS
