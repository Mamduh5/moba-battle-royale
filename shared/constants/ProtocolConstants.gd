class_name ProtocolConstants
extends RefCounted

const VERSION := "arena-protocol-1"
const CLIENT_HELLO := "client_hello"
const SERVER_WELCOME := "server_welcome"
const JOIN_MATCH := "join_match"
const JOIN_ACCEPTED := "join_accepted"
const JOIN_REJECTED := "join_rejected"
const PLAYER_INPUT := "player_input"
const INPUT_ACK := "input_ack"
const WORLD_SNAPSHOT := "world_snapshot"
const COMBAT_EVENT_BATCH := "combat_event_batch"
const CORRECTION := "correction"
const MATCH_FINISHED := "match_finished"

static func known_message_types() -> Array[String]:
	return [
		CLIENT_HELLO,
		SERVER_WELCOME,
		JOIN_MATCH,
		JOIN_ACCEPTED,
		JOIN_REJECTED,
		PLAYER_INPUT,
		INPUT_ACK,
		WORLD_SNAPSHOT,
		COMBAT_EVENT_BATCH,
		CORRECTION,
		MATCH_FINISHED,
	]
