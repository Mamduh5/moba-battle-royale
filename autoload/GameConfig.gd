extends Node

var _env := "local"
var _tick_rate := 30
var _nakama_scheme := "http"
var _nakama_host := "127.0.0.1"
var _nakama_port := 7350
var _match_server_host := "127.0.0.1"
var _match_server_port := 24560
var _content_path := "res://content"

func _ready() -> void:
	var env_name := OS.get_environment("ARENA_ENV")
	if env_name != "":
		_env = env_name
	var server_host := OS.get_environment("ARENA_MATCH_HOST")
	if server_host != "":
		_match_server_host = server_host
	var server_port := OS.get_environment("ARENA_MATCH_PORT")
	if server_port.is_valid_int():
		_match_server_port = int(server_port)

func get_env() -> String:
	return _env

func get_protocol_version() -> String:
	return ProtocolConstants.VERSION

func get_tick_rate() -> int:
	return _tick_rate

func get_nakama_scheme() -> String:
	return _nakama_scheme

func get_nakama_host() -> String:
	return _nakama_host

func get_nakama_port() -> int:
	return _nakama_port

func get_match_server_host() -> String:
	return _match_server_host

func get_match_server_port() -> int:
	return _match_server_port

func get_content_path() -> String:
	return _content_path
