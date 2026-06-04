class_name SnapshotDiffTool
extends RefCounted

func diff(a: SnapshotFrame, b: SnapshotFrame) -> Dictionary:
	return {
		"tick_a": a.server_tick,
		"tick_b": b.server_tick,
		"entity_delta": b.entities.size() - a.entities.size(),
		"event_delta": b.events.size() - a.events.size(),
	}
