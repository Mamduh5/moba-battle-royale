class_name MatchScene
extends Node2D

var arena := ArenaView.new()
var binder := EntityViewBinder.new()
var camera := ArenaCamera.new()
var _map_def: MapDef = null
var _local_player_id := ""

func _ready() -> void:
	add_child(arena)
	add_child(binder)
	add_child(camera)
	camera.enabled = true

func setup(map_def: MapDef, local_player_id: String) -> void:
	_map_def = map_def
	_local_player_id = local_player_id
	arena.setup(map_def)
	binder.set_local_player_id(local_player_id)
	if map_def != null:
		var bounds := map_def.get_bounds_rect()
		camera.limit_left = int(bounds.position.x)
		camera.limit_top = int(bounds.position.y)
		camera.limit_right = int(bounds.position.x + bounds.size.x)
		camera.limit_bottom = int(bounds.position.y + bounds.size.y)

func apply_snapshot(snapshot: SnapshotFrame) -> void:
	if snapshot == null:
		return
	binder.apply_snapshot(snapshot)
	var local_pos := _find_local_position(snapshot)
	if local_pos != Vector2.INF:
		camera.position = local_pos

func clear() -> void:
	binder.clear()

func get_local_screen_origin() -> Vector2:
	return get_viewport().get_visible_rect().size * 0.5

func _find_local_position(snapshot: SnapshotFrame) -> Vector2:
	for entity in snapshot.entities:
		if str(entity.get("owner_player_id", "")) == _local_player_id and str(entity.get("kind", "")) == "hero":
			var pos: Dictionary = entity.get("position", {})
			return Vector2(float(pos.get("x", 0.0)), float(pos.get("y", 0.0)))
	return Vector2.INF
