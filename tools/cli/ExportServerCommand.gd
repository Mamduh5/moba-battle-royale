class_name ExportServerCommand
extends RefCounted

func run(options: Dictionary = {}) -> int:
	var preset := str(options.get("preset", "linux_dedicated"))
	var out := str(options.get("out", "build/server/game_server.x86_64"))
	print(JSON.stringify({"cmd": "export-server", "status": "manual", "preset": preset, "out": out, "godot_command": "godot --headless --path . --export-release %s %s" % [preset, out]}))
	return 0
