class_name KeyboardMouseInputAdapter
extends RefCounted

func sample(player_id: String, client_tick: int, sequence: int) -> InputFrame:
	return InputSampler.new().sample(player_id, client_tick, sequence)
