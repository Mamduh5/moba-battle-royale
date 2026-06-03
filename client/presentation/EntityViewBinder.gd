class_name EntityViewBinder
extends Node2D

var _views: Dictionary = {}
var _vfx := AbilityVfxRouter.new()
var _floating_text := FloatingTextPresenter.new()
var _local_player_id := ""

func _ready() -> void:
	add_child(_vfx)
	add_child(_floating_text)

func set_local_player_id(player_id: String) -> void:
	_local_player_id = player_id

func apply_snapshot(snapshot: SnapshotFrame) -> void:
	var seen: Dictionary = {}
	for entity in snapshot.entities:
		var entity_id := int(entity.get("entity_id", 0))
		seen[entity_id] = true
		if not _views.has(entity_id):
			_views[entity_id] = _create_view(entity)
			add_child(_views[entity_id])
		var view: Node2D = _views[entity_id]
		if entity.get("kind", "") == "hero":
			view.apply_data(entity, _local_player_id)
		elif entity.get("kind", "") == "projectile":
			view.apply_data(entity)
	for entity_id in _views.keys():
		if not seen.has(entity_id):
			var view: Node = _views[entity_id]
			view.queue_free()
			_views.erase(entity_id)
	apply_events(snapshot.events)

func apply_events(events: Array[Dictionary]) -> void:
	var enriched: Array[Dictionary] = []
	for event in events:
		var display_event := event.duplicate(true)
		var source_id := int(display_event.get("source_entity_id", 0))
		var target_id := int(display_event.get("target_entity_id", 0))
		if source_id != 0 and _views.has(source_id):
			var source_view: Node2D = _views[source_id]
			display_event["source_position"] = {"x": source_view.position.x, "y": source_view.position.y}
		if target_id != 0 and _views.has(target_id):
			var target_view: Node2D = _views[target_id]
			display_event["target_position"] = {"x": target_view.position.x, "y": target_view.position.y}
		enriched.append(display_event)
	_vfx.apply_events(enriched)
	for event in events:
		if str(event.get("type", "")) == "damage_applied":
			var target_id := int(event.get("target_entity_id", 0))
			if _views.has(target_id):
				_floating_text.add_text("-%d" % int(event.get("amount", 0)), _views[target_id].position + Vector2(0, -38), Color(1.0, 0.35, 0.25))

func clear() -> void:
	for view in _views.values():
		view.queue_free()
	_views.clear()

func _create_view(entity: Dictionary) -> Node2D:
	if str(entity.get("kind", "")) == "projectile":
		return ProjectileActor.new()
	return HeroActor.new()
