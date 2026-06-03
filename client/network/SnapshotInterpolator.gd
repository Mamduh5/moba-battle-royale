class_name SnapshotInterpolator
extends RefCounted

var _snapshots: Array[SnapshotFrame] = []
var _max_snapshots := 4

func push(snapshot: SnapshotFrame) -> void:
	_snapshots.append(snapshot)
	while _snapshots.size() > _max_snapshots:
		_snapshots.pop_front()

func latest() -> SnapshotFrame:
	if _snapshots.is_empty():
		return null
	return _snapshots[_snapshots.size() - 1]

func clear() -> void:
	_snapshots.clear()
