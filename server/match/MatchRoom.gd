class_name MatchRoom
extends RefCounted

var match_id := ""
var mode_id := GameConstants.MODE_TEAM_ARENA
var map_id := GameConstants.DEFAULT_MAP
var room_code := ""
var _content_db: Object = null
var _world := SimulationWorld.new()
var _sessions: Dictionary = {}
var _roster: Array[Dictionary] = []
var _bot_manager := ServerBotManager.new()
var _spawn_service := SpawnService.new()
var _result_builder := MatchResultBuilder.new()
var _result_reporter := MatchResultReporter.new()
var _clock := SimulationClock.new()
var _started := false
var _reported := false
var _last_snapshot: SnapshotFrame = null
var _last_events: Array[Dictionary] = []
var _seed := 1001

func configure(match_config: Dictionary, content_db: Object) -> void:
	_content_db = content_db
	mode_id = str(match_config.get("mode_id", GameConstants.MODE_TEAM_ARENA))
	var mode: ModeDef = _content_db.get_mode(mode_id)
	map_id = str(match_config.get("map_id", mode.map_id if mode != null else GameConstants.DEFAULT_MAP))
	match_id = str(match_config.get("match_id", "match_%d" % Time.get_ticks_msec()))
	room_code = str(match_config.get("room_code", "ROOM%04d" % (Time.get_ticks_msec() % 10000)))
	_seed = int(match_config.get("seed", Time.get_ticks_msec() % 999999))
	_clock.configure(30)
	var backend: Object = match_config.get("backend", null)
	_result_reporter.configure(backend)

func add_session(session: ClientSession) -> void:
	if _started:
		return
	if session.player_id == "":
		session.player_id = "player_%02d" % (_sessions.size() + 1)
	_sessions[session.player_id] = session

func remove_session(player_id: String, reason: String) -> void:
	if _sessions.has(player_id):
		var session: ClientSession = _sessions[player_id]
		session.connected = false
		_sessions[player_id] = session
	_world.get_state().push_event({"type": "player_disconnected", "player_id": player_id, "reason": reason})

func receive_input(player_id: String, input: InputFrame) -> void:
	if not _sessions.has(player_id):
		return
	var session: ClientSession = _sessions[player_id]
	if input.input_sequence <= session.last_input_sequence and not session.is_bot:
		return
	session.last_input_sequence = input.input_sequence
	_sessions[player_id] = session
	_world.queue_input(input)

func start_match() -> void:
	if _started:
		return
	var mode: ModeDef = _content_db.get_mode(mode_id)
	var map: MapDef = _content_db.get_map(map_id)
	assert(mode != null)
	assert(map != null)
	_roster = _build_human_roster(mode)
	_fill_bots(mode)
	_world.configure(SimulationConfig.from_defs(mode, map, 30), _content_db)
	_world.reset(_seed, mode.id, map.id)
	var profile: BotProfileDef = _content_db.get_bot_profile(mode.bot_profile_id)
	_bot_manager.configure(_content_db, profile)
	for i in range(_roster.size()):
		var entry: Dictionary = _roster[i]
		var spawn_id := _spawn_service.choose_spawn(mode, map, int(entry.get("team_id", 0)), i)
		var entity_id := _world.add_player(str(entry.get("player_id", "")), str(entry.get("hero_id", GameConstants.DEFAULT_HERO)), int(entry.get("team_id", 0)), spawn_id)
		if bool(entry.get("is_bot", false)):
			_bot_manager.register_bot(str(entry.get("player_id", "")), str(entry.get("hero_id", GameConstants.DEFAULT_HERO)))
		var session: ClientSession = _sessions[str(entry.get("player_id", ""))]
		session.team_id = int(entry.get("team_id", 0))
		_sessions[session.player_id] = session
		_world.get_state().push_event({
			"type": "participant_ready",
			"player_id": session.player_id,
			"entity_id": entity_id,
			"team_id": session.team_id,
			"is_bot": session.is_bot,
		})
	_started = true

func tick(delta: float) -> void:
	if not _started:
		start_match()
	if is_finished():
		return
	var steps := _clock.advance(delta)
	for _i in range(steps):
		for frame in _bot_manager.build_inputs(_world.get_state()):
			receive_input(frame.player_id, frame)
		_last_events = _world.step_tick()
		_last_snapshot = _world.build_snapshot()
		if _world.get_state().match_status == GameConstants.MATCH_STATE_FINISHED:
			_report_result_once()
			break

func is_finished() -> bool:
	return _world.get_state().match_status == GameConstants.MATCH_STATE_FINISHED

func build_result() -> Dictionary:
	return _result_builder.build(_world.get_state())

func get_world() -> SimulationWorld:
	return _world

func get_last_snapshot() -> SnapshotFrame:
	if _last_snapshot == null:
		_last_snapshot = _world.build_snapshot()
	return _last_snapshot

func get_last_events() -> Array[Dictionary]:
	return _last_events.duplicate(true)

func get_roster() -> Array[Dictionary]:
	return _roster.duplicate(true)

func get_session(player_id: String) -> ClientSession:
	return _sessions.get(player_id, null)

func _build_human_roster(mode: ModeDef) -> Array[Dictionary]:
	var roster: Array[Dictionary] = []
	var human_index := 0
	for player_id in _sessions.keys():
		var session: ClientSession = _sessions[player_id]
		if session.is_bot:
			continue
		var team := session.team_id
		if team == GameConstants.TEAM_NONE:
			team = TeamService.assign_team_for_index(mode, human_index, mode.friend_team_mode)
		roster.append({
			"player_id": session.player_id,
			"hero_id": session.selected_hero_id,
			"team_id": team,
			"is_bot": false,
		})
		human_index += 1
	return roster

func _fill_bots(mode: ModeDef) -> void:
	var profile: BotProfileDef = _content_db.get_bot_profile(mode.bot_profile_id)
	var hero_pool: Array = profile.hero_pool if profile != null else [GameConstants.DEFAULT_HERO]
	var target_count := mode.max_participants
	var index := 0
	while _roster.size() < target_count:
		var bot_id := "%s%02d" % [GameConstants.BOT_PREFIX, index + 1]
		while _sessions.has(bot_id):
			index += 1
			bot_id = "%s%02d" % [GameConstants.BOT_PREFIX, index + 1]
		var hero_id := str(hero_pool[index % hero_pool.size()])
		var team := TeamService.next_balanced_team(mode, _roster)
		var session := ClientSession.bot(bot_id, hero_id, team)
		_sessions[bot_id] = session
		_roster.append({
			"player_id": bot_id,
			"hero_id": hero_id,
			"team_id": team,
			"is_bot": true,
		})
		index += 1

func _report_result_once() -> void:
	if _reported:
		return
	_reported = true
	_result_reporter.report_result(build_result())
