class_name ExportServerCommand
extends RefCounted

func run(args: Dictionary) -> int:
	var preset := str(args.get("preset", "linux_dedicated"))
	var out := str(args.get("out", "build/server/game_server.x86_64"))
	print("export-server: preset=%s out=%s" % [preset, out])
	print("export-server: run with Godot export templates: godot --headless --path . --export-release %s %s" % [preset, out])
	return ProtocolConstants.EXIT_SUCCESS
