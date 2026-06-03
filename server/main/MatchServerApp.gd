class_name MatchServerApp
extends RefCounted

var _server := MatchServer.new()

func boot(args: Dictionary) -> int:
	if not ContentDB.load_all():
		return ProtocolConstants.EXIT_CONTENT_VALIDATION_FAILURE
	var errors := ContentDB.validate_all()
	if not errors.is_empty():
		return ProtocolConstants.EXIT_CONTENT_VALIDATION_FAILURE
	var host := str(args.get("host", "127.0.0.1"))
	var port := int(args.get("port", 24560))
	if not _server.start(host, port):
		return ProtocolConstants.EXIT_SERVER_BOOT_FAILURE
	return ProtocolConstants.EXIT_SUCCESS

func shutdown(reason: String) -> void:
	print("match_server_shutdown: %s" % reason)
	_server.stop()
