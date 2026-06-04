class_name MatchServerApp
extends Node

var _server := MatchServer.new()

func boot(args: Dictionary) -> int:
	if not ContentDB.load_all():
		return 3
	var host := str(args.get("host", GameConfig.get_match_server_host()))
	var port := int(args.get("port", GameConfig.get_match_server_port()))
	if not _server.start(host, port):
		return 6
	return 0

func shutdown(reason: String) -> void:
	_server.stop()
	DebugBus.info("server", "shutdown", {"reason": reason})
