class_name MatchResultReporter
extends RefCounted

var _backend: Object = null

func configure(backend: Object) -> void:
	_backend = backend

func report_result(result: Dictionary) -> Dictionary:
	if _backend == null:
		return {"accepted": true, "backend": "none", "reward_grants": {}}
	if _backend.has_method("submit_match_result"):
		return _backend.submit_match_result(result)
	return {"accepted": false, "error": "backend_missing_submit_match_result"}
