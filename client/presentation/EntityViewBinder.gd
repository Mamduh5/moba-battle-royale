class_name EntityViewBinder
extends RefCounted

var latest_snapshot: SnapshotFrame = null
var latest_events: Array[Dictionary] = []

func apply_snapshot(snapshot: SnapshotFrame) -> void:
	latest_snapshot = snapshot

func apply_events(events: Array[Dictionary]) -> void:
	latest_events = events.duplicate(true)

func clear() -> void:
	latest_snapshot = null
	latest_events.clear()
