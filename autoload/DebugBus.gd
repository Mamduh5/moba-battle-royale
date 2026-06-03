extends Node

var _trace_enabled := false
var _trace_lines: Array[Dictionary] = []

func info(category: String, event: String, fields: Dictionary = {}) -> void:
	_emit("info", category, event, fields)

func warn(category: String, event: String, fields: Dictionary = {}) -> void:
	_emit("warn", category, event, fields)

func error(category: String, event: String, fields: Dictionary = {}) -> void:
	_emit("error", category, event, fields)

func set_trace_enabled(enabled: bool) -> void:
	_trace_enabled = enabled

func write_trace_line(fields: Dictionary) -> void:
	if not _trace_enabled:
		return
	var line := fields.duplicate(true)
	line["time_ms"] = Time.get_ticks_msec()
	_trace_lines.append(line)

func get_trace_lines() -> Array[Dictionary]:
	return _trace_lines.duplicate(true)

func _emit(level: String, category: String, event: String, fields: Dictionary) -> void:
	var line := fields.duplicate(true)
	line["level"] = level
	line["category"] = category
	line["event"] = event
	line["time_ms"] = Time.get_ticks_msec()
	if _trace_enabled:
		_trace_lines.append(line.duplicate(true))
	var text := JSON.stringify(line)
	if level == "error":
		push_error(text)
	elif level == "warn":
		push_warning(text)
	else:
		print(text)
