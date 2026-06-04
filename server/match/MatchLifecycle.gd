class_name MatchLifecycle
extends RefCounted

enum Phase { CREATED, FILLING, RUNNING, FINISHED }

var phase := Phase.CREATED

func set_running() -> void:
	phase = Phase.RUNNING

func set_finished() -> void:
	phase = Phase.FINISHED

func is_running() -> bool:
	return phase == Phase.RUNNING
