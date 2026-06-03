class_name PredictionBuffer
extends RefCounted

var _inputs: Array[Dictionary] = []
var _max_frames := 120

func push_input(frame: InputFrame) -> void:
	_inputs.append(frame.to_dict())
	while _inputs.size() > _max_frames:
		_inputs.pop_front()

func acknowledge(last_processed_input: int) -> void:
	_inputs = _inputs.filter(func(entry: Dictionary) -> bool:
		return int(entry.get("input_sequence", 0)) > last_processed_input
	)

func get_pending() -> Array[Dictionary]:
	return _inputs.duplicate(true)
