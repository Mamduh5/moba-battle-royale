class_name PredictionBuffer
extends RefCounted

var inputs: Array[Dictionary] = []

func push_input(frame: InputFrame) -> void:
	inputs.append(frame.to_dict())

func clear_acknowledged(last_sequence: int) -> void:
	inputs = inputs.filter(func(item: Dictionary) -> bool: return int(item.get("input_sequence", 0)) > last_sequence)
