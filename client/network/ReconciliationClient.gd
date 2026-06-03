class_name ReconciliationClient
extends RefCounted

var last_correction: Dictionary = {}

func apply_correction(correction: Dictionary) -> void:
	last_correction = correction.duplicate(true)
