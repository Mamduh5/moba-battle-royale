class_name ReplayTraceReader
extends RefCounted

func parse_lines(lines: PackedStringArray) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for line in lines:
		var parsed = JSON.parse_string(line)
		if typeof(parsed) == TYPE_DICTIONARY:
			out.append(parsed)
	return out
