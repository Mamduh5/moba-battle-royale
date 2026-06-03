class_name FriendSmokeCommand
extends RefCounted

func run(args: Dictionary, content_db: Object) -> int:
	content_db.load_all()
	var validation_errors: Array[String] = content_db.validate_all()
	if not validation_errors.is_empty():
		for error in validation_errors:
			printerr("friend_smoke_content_error: %s" % error)
		return ProtocolConstants.EXIT_CONTENT_VALIDATION_FAILURE
	var mode_id := str(args.get("mode", GameConstants.MODE_TEAM_ARENA))
	var mode: ModeDef = content_db.get_mode(mode_id)
	if mode == null:
		printerr("friend-smoke missing mode: %s" % mode_id)
		return ProtocolConstants.EXIT_INVALID_ARGUMENTS
	var port := int(args.get("port", 24680))
	var result := _run_two_client_smoke(content_db, mode, port)
	if not result.get("ok", false):
		for error in result.get("errors", []):
			printerr("friend_smoke_failure: %s" % error)
		return ProtocolConstants.EXIT_SERVER_BOOT_FAILURE
	print("friend-smoke: ok mode=%s humans=2 bots=%d snapshots=%d match_finished=%s network_events=%d" % [
		mode_id,
		mode.max_participants - 2,
		int(result.get("snapshots_received", 0)),
		str(result.get("match_finished", false)),
		int(result.get("network_events", 0)),
	])
	return ProtocolConstants.EXIT_SUCCESS

func _run_two_client_smoke(content_db: Object, mode: ModeDef, port: int) -> Dictionary:
	var errors: Array[String] = []
	var transport := TcpServerTransport.new()
	if not transport.start("127.0.0.1", port):
		return {"ok": false, "errors": ["failed to start TCP transport on 127.0.0.1:%d" % port]}
	var room := MatchRoom.new()
	room.configure({"mode_id": mode.id, "match_id": "friend_%s_%d" % [mode.id, Time.get_ticks_msec()], "seed": 44001}, content_db)
	var clients := [TcpFriendClient.new(), TcpFriendClient.new()]
	var player_ids := ["friend_player_1", "friend_player_2"]
	for i in range(clients.size()):
		var client: TcpFriendClient = clients[i]
		if not client.connect_to_host("127.0.0.1", port, player_ids[i]):
			errors.append("client %s failed connect_to_host" % player_ids[i])
	_poll_all(transport, clients, 10)
	for i in range(clients.size()):
		var client: TcpFriendClient = clients[i]
		client.send(ProtocolConstants.MSG_CLIENT_HELLO, {"client_build": GameConstants.BUILD_VERSION, "platform": "desktop", "preferred_snapshot_rate": 15})
		client.send(ProtocolConstants.MSG_JOIN_MATCH, {
			"nakama_user_id": "local_%s" % player_ids[i],
			"session_id": "session_%s" % player_ids[i],
			"match_token": "dev-token-%s" % player_ids[i],
			"selected_hero_id": "hero_guardian" if i == 0 else "hero_shade",
			"client_region": "local",
		})
	var joined: Dictionary = {}
	var snapshots_received := 0
	var finished_by_client: Dictionary = {}
	var room_started := false
	var input_sequence := 0
	var max_ticks := mode.duration_sec * 30 + 900
	for tick in range(max_ticks):
		transport.poll_network()
		for message in transport.drain_messages():
			var peer_id := str(message.get("peer_id", ""))
			var message_type := str(message.get("message_type", ""))
			var payload: Dictionary = message.get("payload", {})
			if message_type == ProtocolConstants.MSG_CLIENT_HELLO:
				transport.send_to_peer(peer_id, ProtocolConstants.MSG_SERVER_WELCOME, {
					"server_build": GameConstants.BUILD_VERSION,
					"authoritative_tick_rate": 30,
					"snapshot_rate": 15,
					"server_time_ms": Time.get_ticks_msec(),
				})
			elif message_type == ProtocolConstants.MSG_JOIN_MATCH:
				var player_id: String = player_ids[joined.size()]
				var hero_id := str(payload.get("selected_hero_id", GameConstants.DEFAULT_HERO))
				room.add_session(ClientSession.human(player_id, hero_id))
				joined[player_id] = peer_id
				transport.send_to_peer(peer_id, ProtocolConstants.MSG_JOIN_ACCEPTED, {
					"match_id": room.match_id,
					"player_id": player_id,
					"team_id": GameConstants.TEAM_A,
					"hero_id": hero_id,
					"server_tick": 0,
					"map_id": mode.map_id,
					"mode_id": mode.id,
				})
			elif message_type == ProtocolConstants.MSG_PLAYER_INPUT:
				var frame := InputFrame.from_dict(payload)
				room.receive_input(frame.player_id, frame)
		if joined.size() == 2 and not room_started:
			room.start_match()
			room_started = true
		if room_started and not room.is_finished():
			input_sequence += 1
			for i in range(clients.size()):
				var frame := InputFrame.new()
				frame.player_id = player_ids[i]
				frame.input_sequence = input_sequence
				frame.client_tick = tick
				frame.aim_x = 1.0 if i == 0 else -1.0
				frame.aim_y = 0.0
				frame.buttons[GameConstants.SLOT_BASIC] = true
				frame.cast_requests.append({
					"slot": GameConstants.SLOT_BASIC,
					"ability_id": "ability_guardian_basic" if i == 0 else "ability_shade_basic",
					"target_entity_id": 0,
					"target_position": {"x": 0.0, "y": 0.0},
					"aim": {"x": frame.aim_x, "y": frame.aim_y},
				})
				clients[i].send_input(frame)
			room.tick(1.0 / 30.0)
			var snapshot := room.get_last_snapshot()
			var snapshot_payload := snapshot.to_dict()
			for peer_id in joined.values():
				transport.send_to_peer(str(peer_id), ProtocolConstants.MSG_WORLD_SNAPSHOT, snapshot_payload)
		elif room_started and room.is_finished():
			var result := room.build_result()
			for peer_id in joined.values():
				transport.send_to_peer(str(peer_id), ProtocolConstants.MSG_MATCH_FINISHED, result)
			_poll_all(transport, clients, 10)
			break
		_poll_all(transport, clients, 1)
		for client in clients:
			for message in client.drain_messages():
				var type := str(message.get("message_type", ""))
				if type == ProtocolConstants.MSG_WORLD_SNAPSHOT:
					snapshots_received += 1
				elif type == ProtocolConstants.MSG_MATCH_FINISHED:
					finished_by_client[client.player_id] = true
	if not room_started:
		errors.append("room did not start after two client joins")
	if room_started:
		var roster := room.get_roster()
		if roster.size() != mode.max_participants:
			errors.append("roster expected %d got %d" % [mode.max_participants, roster.size()])
		var bot_count := 0
		for entry in roster:
			if bool(entry.get("is_bot", false)):
				bot_count += 1
		if bot_count != mode.max_participants - 2:
			errors.append("bot fill expected %d got %d" % [mode.max_participants - 2, bot_count])
	if snapshots_received <= 0:
		errors.append("clients did not receive world snapshots")
	if not room.is_finished():
		errors.append("match did not finish within smoke limit")
	for client in clients:
		client.close_connection()
	transport.stop()
	var network_events := transport.get_network_log().size()
	for client in clients:
		network_events += client.get_network_log().size()
	return {
		"ok": errors.is_empty(),
		"errors": errors,
		"snapshots_received": snapshots_received,
		"match_finished": room.is_finished(),
		"network_events": network_events,
	}

func _poll_all(transport: TcpServerTransport, clients: Array, iterations: int) -> void:
	for _i in range(iterations):
		transport.poll_network()
		for client in clients:
			client.poll_network()
		OS.delay_msec(2)
