class_name BotPerception
extends RefCounted

var self_entity_id := 0
var self_player_id := ""
var self_team_id := 0
var self_health_ratio := 1.0
var visible_enemies: Array[Dictionary] = []
var nearby_allies: Array[Dictionary] = []
var objectives: Array[Dictionary] = []
var incoming_threats: Array[Dictionary] = []
var current_tick := 0
var map_hints: Dictionary = {}
