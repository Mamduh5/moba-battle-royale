extends Node

const DEFAULT_PROTOCOL_VERSION := "arena-protocol-1"
const DEFAULT_TICK_RATE := 30
const CLIENT_BUILD := "0.1.0-dev"

var _env := "local"

func _ready() -> void:
	_env = OS.get_environment("ARENA_ENV") if OS.has_environment("ARENA_ENV") else "local"

func get_env() -> String:
	return _env

func get_protocol_version() -> String:
	return DEFAULT_PROTOCOL_VERSION

func get_tick_rate() -> int:
	return DEFAULT_TICK_RATE

func get_client_build() -> String:
	return CLIENT_BUILD

func get_content_path() -> String:
	return "res://content"

func get_nakama_scheme() -> String:
	return "http" if _env == "local" else "https"

func get_nakama_host() -> String:
	return OS.get_environment("NAKAMA_HOST") if OS.has_environment("NAKAMA_HOST") else "127.0.0.1"

func get_nakama_port() -> int:
	return int(OS.get_environment("NAKAMA_PORT")) if OS.has_environment("NAKAMA_PORT") else 7350

func get_match_server_host() -> String:
	return OS.get_environment("MATCH_SERVER_HOST") if OS.has_environment("MATCH_SERVER_HOST") else "127.0.0.1"

func get_match_server_port() -> int:
	return int(OS.get_environment("MATCH_SERVER_PORT")) if OS.has_environment("MATCH_SERVER_PORT") else 24560
