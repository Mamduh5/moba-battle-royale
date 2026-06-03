class_name ProtocolConstants
extends RefCounted

const VERSION := "arena-protocol-1"
const MSG_CLIENT_HELLO := "client_hello"
const MSG_SERVER_WELCOME := "server_welcome"
const MSG_JOIN_MATCH := "join_match"
const MSG_JOIN_ACCEPTED := "join_accepted"
const MSG_JOIN_REJECTED := "join_rejected"
const MSG_PLAYER_INPUT := "player_input"
const MSG_INPUT_ACK := "input_ack"
const MSG_WORLD_SNAPSHOT := "world_snapshot"
const MSG_COMBAT_EVENT_BATCH := "combat_event_batch"
const MSG_CORRECTION := "correction"
const MSG_MATCH_FINISHED := "match_finished"

const EXIT_SUCCESS := 0
const EXIT_GENERIC_FAILURE := 1
const EXIT_INVALID_ARGUMENTS := 2
const EXIT_CONTENT_VALIDATION_FAILURE := 3
const EXIT_TEST_FAILURE := 4
const EXIT_PROTOCOL_FAILURE := 5
const EXIT_SERVER_BOOT_FAILURE := 6
const EXIT_BOT_SOAK_FAILURE := 7

static func known_message_types() -> Array[String]:
	return [
		MSG_CLIENT_HELLO,
		MSG_SERVER_WELCOME,
		MSG_JOIN_MATCH,
		MSG_JOIN_ACCEPTED,
		MSG_JOIN_REJECTED,
		MSG_PLAYER_INPUT,
		MSG_INPUT_ACK,
		MSG_WORLD_SNAPSHOT,
		MSG_COMBAT_EVENT_BATCH,
		MSG_CORRECTION,
		MSG_MATCH_FINISHED,
	]
