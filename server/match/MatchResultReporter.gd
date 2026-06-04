class_name MatchResultReporter
extends RefCounted

var backend: LocalNakamaAdapter = null

func _init() -> void:
	backend = LocalNakamaAdapter.new()

func report_result(result: Dictionary) -> Dictionary:
	return backend.submit_match_result(result)
