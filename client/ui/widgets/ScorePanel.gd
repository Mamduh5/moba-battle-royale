class_name ScorePanel
extends Control

var snapshot: SnapshotFrame = null
var player_id := GameConstants.LOCAL_PLAYER_ID

func _ready() -> void:
	custom_minimum_size = Vector2(330, 138)

func set_snapshot(next_snapshot: SnapshotFrame, local_player_id: String) -> void:
	snapshot = next_snapshot
	player_id = local_player_id
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#101826", 0.82), true)
	draw_rect(Rect2(Vector2.ZERO, size), ArenaTheme.COLOR_BLUE, false, 2.0)
	if snapshot == null:
		return
	var scoreboard: Dictionary = snapshot.scoreboard
	var mode_id := str(scoreboard.get("mode_id", ""))
	if mode_id == "3v3_team_arena":
		var teams: Dictionary = scoreboard.get("teams", {})
		var blue: Dictionary = teams.get("1", {"score": 0})
		var red: Dictionary = teams.get("2", {"score": 0})
		_text("BLUE %02d" % int(blue.get("score", 0)), Vector2(18, 36), 24, ArenaTheme.COLOR_BLUE)
		_text("RED %02d" % int(red.get("score", 0)), Vector2(size.x - 122, 36), 24, ArenaTheme.COLOR_RED)
		_text(_timer_text(scoreboard), Vector2(size.x * 0.5 - 36, 36), 24, ArenaTheme.COLOR_GOLD)
	else:
		_text("TOP RANKS", Vector2(18, 30), 18, ArenaTheme.COLOR_GOLD)
		var rankings: Array = scoreboard.get("rankings", [])
		for i in range(min(5, rankings.size())):
			var entry: Dictionary = rankings[i]
			var color := ArenaTheme.COLOR_TEXT if str(entry.get("player_id", "")) == player_id else ArenaTheme.COLOR_MUTED
			_text("#%d %s  %d/%d" % [int(entry.get("rank", i + 1)), str(entry.get("display_name", "")), int(entry.get("score", 0)), int(entry.get("deaths", 0))], Vector2(18, 56 + i * 20), 15, color)
		_text(_timer_text(scoreboard), Vector2(size.x - 70, 30), 18, ArenaTheme.COLOR_GOLD)

func _timer_text(scoreboard: Dictionary) -> String:
	var ticks := int(scoreboard.get("ticks_remaining", 0))
	var sec := int(ceil(float(ticks) / 30.0))
	return "%02d:%02d" % [int(sec / 60), sec % 60]

func _text(text: String, pos: Vector2, font_size: int, color: Color) -> void:
	draw_string(get_theme_default_font(), pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)
