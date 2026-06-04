extends SceneTree

const EXIT_SUCCESS := 0
const EXIT_GENERIC_FAILURE := 1
const EXIT_INVALID_ARGS := 2
const EXIT_CONTENT_FAILURE := 3
const EXIT_TEST_FAILURE := 4
const EXIT_PROTOCOL_FAILURE := 5
const EXIT_SERVER_FAILURE := 6
const EXIT_BOT_SOAK_FAILURE := 7

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var parsed := _parse_args(OS.get_cmdline_user_args())
	var exit_code := await _dispatch(parsed)
	quit(exit_code)

func _parse_args(args: PackedStringArray) -> Dictionary:
	var parsed := {"cmd": "", "options": {}}
	var i := 0
	while i < args.size():
		var token := args[i]
		if token == "--cmd" and i + 1 < args.size():
			parsed["cmd"] = args[i + 1]
			i += 2
			continue
		if token.begins_with("--") and i + 1 < args.size():
			parsed["options"][token.substr(2)] = args[i + 1]
			i += 2
			continue
		if token.begins_with("--"):
			parsed["options"][token.substr(2)] = "true"
		i += 1
	return parsed

func _dispatch(parsed: Dictionary) -> int:
	match parsed.get("cmd", ""):
		"validate-content":
			return load("res://tools/cli/ValidateContentCommand.gd").new().run(parsed["options"])
		"run-tests":
			return load("res://tools/cli/RunTestsCommand.gd").new().run(parsed["options"])
		"protocol-check":
			return load("res://tools/cli/ProtocolCheckCommand.gd").new().run(parsed["options"])
		"bot-soak":
			return load("res://tools/cli/BotSoakCommand.gd").new().run(parsed["options"])
		"server-smoke":
			return load("res://tools/cli/ServerSmokeCommand.gd").new().run(parsed["options"])
		"friend-smoke":
			return load("res://tools/cli/FriendSmokeCommand.gd").new().run(parsed["options"])
		"backend-check":
			return load("res://tools/cli/BackendCheckCommand.gd").new().run(parsed["options"])
		"rendered-ui-audit":
			return await load("res://tools/cli/RenderedUiAuditCommand.gd").new().run_async(parsed["options"], self)
		"export-server":
			return load("res://tools/cli/ExportServerCommand.gd").new().run(parsed["options"])
		_:
			printerr("Unknown or missing --cmd")
			return EXIT_INVALID_ARGS
