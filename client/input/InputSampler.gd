class_name InputSampler
extends RefCounted

var _adapter: Object = KeyboardMouseInputAdapter.new()
var _origin_screen := Vector2.ZERO
var _hero_ability_slots: Dictionary = {}

func set_input_adapter(adapter: Object) -> void:
	_adapter = adapter

func set_screen_origin(origin: Vector2) -> void:
	_origin_screen = origin

func set_hero_ability_slots(slots: Dictionary) -> void:
	_hero_ability_slots = slots.duplicate(true)

func sample(player_id: String, client_tick: int, sequence: int) -> InputFrame:
	var frame := InputFrame.new()
	frame.player_id = player_id
	frame.client_tick = client_tick
	frame.input_sequence = sequence
	var move: Vector2 = _adapter.get_move_vector()
	var aim: Vector2 = _adapter.get_aim_vector(Engine.get_main_loop().root, _origin_screen)
	frame.move_x = move.x
	frame.move_y = move.y
	frame.aim_x = aim.x
	frame.aim_y = aim.y
	_sample_button(frame, GameConstants.SLOT_BASIC, true)
	_sample_button(frame, GameConstants.SLOT_ABILITY_1, false)
	_sample_button(frame, GameConstants.SLOT_ABILITY_2, false)
	_sample_button(frame, GameConstants.SLOT_ULTIMATE, false)
	frame.buttons["interact"] = _adapter.is_button_down("interact") if _adapter.has_method("is_button_down") else false
	return frame.normalized()

func _sample_button(frame: InputFrame, slot: String, allow_hold: bool) -> void:
	var action := slot
	var pressed: bool = _adapter.is_button_down(action) if allow_hold else _adapter.is_button_just_pressed(action)
	if _adapter.has_method("consume_latched"):
		pressed = pressed or _adapter.consume_latched(action)
	frame.buttons[slot] = pressed
	if pressed and _hero_ability_slots.has(slot):
		frame.cast_requests.append({
			"slot": slot,
			"ability_id": str(_hero_ability_slots[slot]),
			"target_entity_id": 0,
			"target_position": {"x": 0.0, "y": 0.0},
			"aim": {"x": frame.aim_x, "y": frame.aim_y},
		})
