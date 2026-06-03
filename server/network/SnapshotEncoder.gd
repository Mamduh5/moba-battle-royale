class_name SnapshotEncoder
extends RefCounted

func encode_snapshot(snapshot: SnapshotFrame) -> Dictionary:
	return snapshot.to_dict()
