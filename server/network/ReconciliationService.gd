class_name ReconciliationService
extends RefCounted

func build_input_ack(player_id: String, last_input: int, server_tick: int) -> Dictionary:
	return {"player_id": player_id, "last_processed_input": last_input, "server_tick": server_tick}
