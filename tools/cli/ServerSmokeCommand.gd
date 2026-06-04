class_name ServerSmokeCommand
extends RefCounted

func run(options: Dictionary = {}) -> int:
	var duration_sec := float(options.get("duration-sec", 5.0))
	var content_db := _content_db()
	content_db.load_all()
	var server: MatchServer = load("res://server/network/MatchServer.gd").new()
	if not server.start("127.0.0.1", 24560):
		print(JSON.stringify({"cmd": "server-smoke", "status": "fail", "errors": ["transport failed to start"]}))
		return 6
	var room: MatchRoom = load("res://server/match/MatchRoom.gd").new()
	room.configure({"match_id": "server_smoke", "mode_id": "3v3_team_arena", "seed": 11}, content_db)
	room.add_session(ClientSession.make_human(GameConstants.LOCAL_PLAYER_ID, "hero_guardian", "Local Player"))
	room.start_match()
	var ticks := int(duration_sec * 30.0)
	for _i in range(ticks):
		room.tick_fixed()
	var snapshot := room.get_last_snapshot()
	server.broadcast(room.match_id, ProtocolConstants.WORLD_SNAPSHOT, snapshot.to_dict())
	var outbox := server.get_debug_outbox()
	server.stop()
	var errors: Array[String] = []
	if snapshot.entities.size() != 6:
		errors.append("expected 6 entities in 3v3 smoke")
	if outbox.is_empty():
		errors.append("expected snapshot broadcast")
	if not errors.is_empty():
		print(JSON.stringify({"cmd": "server-smoke", "status": "fail", "errors": errors}))
		return 6
	print(JSON.stringify({"cmd": "server-smoke", "status": "pass", "duration_sec": duration_sec, "entities": snapshot.entities.size(), "network_messages": outbox.size()}))
	return 0

func _content_db() -> Object:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root.get_node("/root/ContentDB")
