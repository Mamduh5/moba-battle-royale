class_name ServerBotManager
extends RefCounted

var _content_db: Object = null
var _profile := BotDifficultyProfile.new()
var _brains: Dictionary = {}
var _sequences: Dictionary = {}
var _debug_enabled := false

func configure(content_db: Object, profile_def: BotProfileDef, debug_enabled: bool = false) -> void:
	_content_db = content_db
	_profile = BotDifficultyProfile.from_def(profile_def)
	_debug_enabled = debug_enabled
	_brains.clear()
	_sequences.clear()

func register_bot(player_id: String, hero_id: String) -> void:
	var brain := BotBrain.new()
	brain.configure(_profile, hero_id)
	_brains[player_id] = brain
	_sequences[player_id] = 0

func unregister(player_id: String) -> void:
	_brains.erase(player_id)
	_sequences.erase(player_id)

func build_inputs(state: SimulationState) -> Array[InputFrame]:
	var frames: Array[InputFrame] = []
	for player_id in _brains.keys():
		var perception := BotPerception.from_state(state, str(player_id))
		if perception.self_entity_id == 0:
			continue
		var sequence := int(_sequences.get(player_id, 0)) + 1
		_sequences[player_id] = sequence
		var brain: BotBrain = _brains[player_id]
		var frame := brain.build_input_frame(perception, state.server_tick, sequence)
		if frame.is_valid():
			frames.append(frame)
	return frames
