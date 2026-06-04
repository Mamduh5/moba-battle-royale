extends Node

var _trace_enabled := false
var _memory_lines: Array[Dictionary] = []

func info(category: String, event: String, fields: Dictionary = {}) -> void:
	_log("info", category, event, fields)

func warn(category: String, event: String, fields: Dictionary = {}) -> void:
	_log("warn", category, event, fields)

func error(category: String, event: String, fields: Dictionary = {}) -> void:
	_log("error", category, event, fields)

func set_trace_enabled(enabled: bool) -> void:
	_trace_enabled = enabled

func write_trace_line(fields: Dictionary) -> void:
	if not _trace_enabled:
		return
	_memory_lines.append(fields.duplicate(true))
	print(JSON.stringify(fields))

func get_memory_lines() -> Array[Dictionary]:
	return _memory_lines.duplicate(true)

func clear() -> void:
	_memory_lines.clear()

func _log(level: String, category: String, event: String, fields: Dictionary) -> void:
	var payload := {
		"level": level,
		"category": category,
		"event": event,
		"time_ms": Time.get_ticks_msec(),
		"fields": fields,
	}
	if not fields.has("match_id"):
		payload["fields"]["match_id"] = ""
	if not fields.has("server_tick"):
		payload["fields"]["server_tick"] = -1
	print(JSON.stringify(payload))
	write_trace_line(payload)
