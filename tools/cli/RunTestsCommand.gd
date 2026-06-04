class_name RunTestsCommand
extends RefCounted

func run(_options: Dictionary = {}) -> int:
	var errors: Array[String] = []
	if load("res://tools/cli/ValidateContentCommand.gd").new().run({}) != 0:
		errors.append("content validation command failed")
	if load("res://tools/cli/ProtocolCheckCommand.gd").new().run({}) != 0:
		errors.append("protocol check command failed")
	_test_input_clamping(errors)
	_test_damage_and_death(errors)
	_test_match_room_bot_only(errors)
	_test_friend_fill(errors)
	if not errors.is_empty():
		print(JSON.stringify({"cmd": "run-tests", "status": "fail", "errors": errors}))
		return 4
	print(JSON.stringify({"cmd": "run-tests", "status": "pass", "unit": 4, "integration": 2, "protocol": 1}))
	return 0

func _test_input_clamping(errors: Array[String]) -> void:
	var frame: InputFrame = load("res://shared/net/InputFrame.gd").new()
	frame.player_id = "test"
	frame.move_x = 4.0
	frame.move_y = 0.0
	var normalized := frame.normalized()
	if normalized.move_x > 1.0:
		errors.append("input clamp failed")

func _test_damage_and_death(errors: Array[String]) -> void:
	var content_db := _content_db()
	content_db.load_all()
	var world: SimulationWorld = load("res://shared/simulation/SimulationWorld.gd").new()
	var config: SimulationConfig = load("res://shared/simulation/SimulationConfig.gd").new()
	world.configure(config, content_db)
	world.reset(1, "3v3_team_arena", "map_skyline_ring")
	var a := world.add_player("a", "hero_guardian", 1, "t1_0")
	var b := world.add_player("b", "hero_raptor", 2, "t2_0")
	world.get_state().patch_entity(a, {"invuln_ticks": 0})
	world.get_state().patch_entity(b, {"invuln_ticks": 0})
	var resolver: DamageResolver = load("res://shared/combat/DamageResolver.gd").new()
	var result: DamageResult = resolver.resolve_damage(DamageRequest.make(a, b, "test", 9999), world.get_state())
	if not result.killed:
		errors.append("damage resolver did not kill target: %s" % [result.to_dict()])
	var target := world.get_state().get_entity(b)
	if target.get("status_tags", []).has(GameConstants.STATUS_ALIVE):
		errors.append("dead target still marked alive")

func _test_match_room_bot_only(errors: Array[String]) -> void:
	var room: MatchRoom = load("res://server/match/MatchRoom.gd").new()
	room.configure({"match_id": "test_bot_only", "mode_id": "3v3_team_arena", "seed": 7}, _content_db())
	room.start_match()
	if room.get_bot_count() != 6:
		errors.append("bot-only 3v3 did not fill 6 bots")
	for _i in range(400):
		room.tick_fixed()
	if room.get_last_snapshot().entities.size() != 6:
		errors.append("bot-only snapshot missing entities")

func _test_friend_fill(errors: Array[String]) -> void:
	var room: MatchRoom = load("res://server/match/MatchRoom.gd").new()
	room.configure({"match_id": "test_friend", "mode_id": "25_player_deathmatch", "participants": 25, "seed": 8}, _content_db())
	room.add_session(ClientSession.make_human("h1", "hero_guardian"))
	room.add_session(ClientSession.make_human("h2", "hero_raptor"))
	room.start_match()
	if room.get_human_count() != 2 or room.get_bot_count() != 23:
		errors.append("friend deathmatch bot fill failed")

func _content_db() -> Object:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root.get_node("/root/ContentDB")
