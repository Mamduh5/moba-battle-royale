class_name MatchRoom
extends RefCounted

var match_id := GameConstants.DEFAULT_MATCH_ID

var _world := SimulationWorld.new()
var _sessions: Dictionary = {}
var _bot_manager := ServerBotManager.new()
var _lifecycle := MatchLifecycle.new()
var _result_builder := MatchResultBuilder.new()
var _result_reporter := MatchResultReporter.new()
var _spawn_service := SpawnService.new()
var _finished := false
var _accumulator := 0.0
var _tick_rate := 30
var _content_db: Object = null
var _mode: ModeDef = null
var _map_id := ""
var _match_config: Dictionary = {}
var _last_snapshot := SnapshotFrame.new()
var _last_events: Array[Dictionary] = []
var _backend_report: Dictionary = {}

func configure(match_config: Dictionary, content_db: Object) -> void:
	_match_config = match_config.duplicate(true)
	match_id = str(match_config.get("match_id", GameConstants.DEFAULT_MATCH_ID))
	_tick_rate = int(match_config.get("tick_rate", 30))
	_content_db = content_db
	_mode = _content_db.get_mode(str(match_config.get("mode_id", "3v3_team_arena")))
	_map_id = str(match_config.get("map_id", _mode.map_id))
	var profile: BotProfileDef = _content_db.get_first_bot_profile()
	if profile != null:
		_bot_manager.configure(profile)
	var config := SimulationConfig.new()
	config.tick_rate = _tick_rate
	_world.configure(config, content_db)
	_world.reset(int(match_config.get("seed", 1)), _mode.id, _map_id)
	_lifecycle.phase = MatchLifecycle.Phase.FILLING

func add_session(session: ClientSession) -> void:
	if _lifecycle.phase == MatchLifecycle.Phase.RUNNING:
		return
	_sessions[session.player_id] = session

func remove_session(player_id: String, reason: String) -> void:
	_sessions.erase(player_id)
	_bot_manager.unregister_bot(player_id)
	_world.remove_player(player_id)
	DebugBus.info("match", "session_removed", {"match_id": match_id, "player_id": player_id, "reason": reason, "server_tick": _world.get_tick()})

func receive_input(player_id: String, input: InputFrame) -> void:
	if not _sessions.has(player_id):
		return
	if input.player_id != player_id:
		return
	var session: ClientSession = _sessions[player_id]
	if input.input_sequence <= session.last_sequence and input.input_sequence != 0:
		return
	session.last_sequence = input.input_sequence
	_world.queue_input(input)

func start_match() -> void:
	if _lifecycle.is_running():
		return
	_assign_humans_and_fill_bots()
	_lifecycle.set_running()
	_last_snapshot = _world.build_snapshot()
	DebugBus.info("match", "match_started", {"match_id": match_id, "mode_id": _mode.id, "participants": _sessions.size(), "server_tick": _world.get_tick()})

func tick(delta: float) -> void:
	if _finished:
		return
	if not _lifecycle.is_running():
		start_match()
	_accumulator += delta
	var step := 1.0 / float(_tick_rate)
	while _accumulator >= step:
		tick_fixed()
		_accumulator -= step

func tick_fixed() -> void:
	if _finished:
		return
	for frame in _bot_manager.build_bot_inputs(_world):
		receive_input(frame.player_id, frame)
	_last_events = _world.step_tick()
	_last_snapshot = _world.build_snapshot()
	_last_snapshot.events = _last_events.duplicate(true)
	_handle_events(_last_events)

func is_finished() -> bool:
	return _finished

func build_result() -> Dictionary:
	var result := _result_builder.build(self)
	if _backend_report.is_empty():
		_backend_report = _result_reporter.report_result(result)
	result["backend_report"] = _backend_report.duplicate(true)
	return result

func get_last_snapshot() -> SnapshotFrame:
	return _last_snapshot

func get_world() -> SimulationWorld:
	return _world

func get_session_count() -> int:
	return _sessions.size()

func get_human_count() -> int:
	var count := 0
	for session in _sessions.values():
		if not session.is_bot:
			count += 1
	return count

func get_bot_count() -> int:
	var count := 0
	for session in _sessions.values():
		if session.is_bot:
			count += 1
	return count

func get_sessions() -> Array:
	return _sessions.values()

func _assign_humans_and_fill_bots() -> void:
	var max_participants := int(_match_config.get("participants", _mode.max_participants))
	max_participants = clampi(max_participants, 1, _mode.max_participants)
	if _mode.id == "3v3_team_arena":
		max_participants = 6
	var team_counts := {"1": 0, "2": 0}
	var human_index := 0
	for session in _sessions.values():
		if session.is_bot:
			continue
		var team_id := _choose_human_team(human_index)
		session.team_id = team_id
		team_counts[str(team_id)] = int(team_counts.get(str(team_id), 0)) + 1
		_add_session_entity(session, human_index)
		human_index += 1
	var bot_profile: BotProfileDef = _content_db.get_first_bot_profile()
	var bot_index := 0
	while _sessions.size() < max_participants:
		var team_id := GameConstants.TEAM_NONE
		if _mode.teams_enabled:
			team_id = TeamService.next_balanced_team(team_counts, _mode.team_count)
			team_counts[str(team_id)] = int(team_counts.get(str(team_id), 0)) + 1
		var hero_id := bot_profile.hero_rotation[bot_index % bot_profile.hero_rotation.size()]
		var session := ClientSession.make_bot("bot_%02d" % bot_index, hero_id, team_id, "Bot %02d" % (bot_index + 1))
		_sessions[session.player_id] = session
		_add_session_entity(session, bot_index + human_index)
		_bot_manager.register_bot(session)
		bot_index += 1

func _choose_human_team(human_index: int) -> int:
	if not _mode.teams_enabled:
		return GameConstants.TEAM_NONE
	var friend_team_mode := str(_match_config.get("friend_team_mode", "together"))
	if friend_team_mode == "split":
		return 1 + (human_index % 2)
	return GameConstants.TEAM_BLUE if human_index < 3 else GameConstants.TEAM_RED

func _add_session_entity(session: ClientSession, roster_index: int) -> void:
	var spawn_id := _spawn_service.get_spawn_id(_mode, roster_index, session.team_id)
	_world.add_player(session.player_id, session.selected_hero_id, session.team_id, spawn_id, session.display_name, session.is_bot)

func _handle_events(events: Array[Dictionary]) -> void:
	for event in events:
		if str(event.get("type", "")) == "match_finished":
			_finished = true
			_lifecycle.set_finished()
			_backend_report = _result_reporter.report_result(_result_builder.build(self))
			DebugBus.info("match", "match_finished", {"match_id": match_id, "server_tick": _world.get_tick(), "reason": str(event.get("reason", ""))})
