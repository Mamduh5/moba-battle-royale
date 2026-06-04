class_name SnapshotInterpolator
extends RefCounted

var latest_snapshot: SnapshotFrame = null

func push_snapshot(snapshot: SnapshotFrame) -> void:
	latest_snapshot = snapshot

func get_presented_snapshot() -> SnapshotFrame:
	return latest_snapshot
