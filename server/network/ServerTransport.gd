class_name ServerTransport
extends RefCounted

func start(_host: String, _port: int) -> bool:
	return true

func stop() -> void:
	pass

func poll_network() -> void:
	pass

func send_to_player(_player_id: String, _message_type: String, _payload: Dictionary) -> void:
	pass

func broadcast(_match_id: String, _message_type: String, _payload: Dictionary) -> void:
	pass
