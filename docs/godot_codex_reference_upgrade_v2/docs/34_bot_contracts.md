# 34 - Bot Contracts

Bots must act through the same input system as human players.

## Required bot pipeline

```text
SimulationState -> BotPerception -> BotBrain -> BotDecision -> BotInputBuilder -> InputFrame -> MatchRoom.receive_input()
```

Forbidden:

```text
Bot directly applies damage
Bot directly changes position
Bot directly captures objective
Bot ignores cooldowns
Bot calls AbilityRuntime.cast() outside normal simulation flow
```

## Bot perception

`BotPerception` contains what the bot is allowed to know.

Required fields:

```gdscript
var self_entity_id: int
var self_team_id: int
var visible_enemies: Array[Dictionary]
var nearby_allies: Array[Dictionary]
var objectives: Array[Dictionary]
var incoming_threats: Array[Dictionary]
var current_tick: int
var map_hints: Dictionary
```

Do not give bots hidden perfect information in production modes unless the difficulty profile explicitly allows it.

## Bot difficulty profile

Fields:

```gdscript
var profile_id: String
var reaction_delay_ticks: int
var aim_error_degrees: float
var aggression: float
var objective_priority: float
var retreat_health_ratio: float
var skill_usage: float
var dodge_skill: float
var map_awareness: float
```

## Bot decision

Required output:

```gdscript
var move_direction: Vector2
var aim_direction: Vector2
var desired_target_entity_id: int
var desired_target_position: Vector2
var cast_slot: String
var interact: bool
var debug_reason: String
```

## Ability scoring

`BotAbilityScorer` scores each ability from 0.0 to 1.0 using:

- target distance
- cooldown availability
- hit chance
- self health
- enemy health
- objective value
- danger level
- mana/energy when implemented

## Movement scoring

`BotObjectiveSelector` chooses one objective:

```text
attack_enemy
protect_ally
capture_objective
retreat_to_safe_zone
return_to_lane_or_center
kite_enemy
```

`BotInputBuilder` converts that decision into an `InputFrame`.

## Bot tests

Required tests:

- low-health bot retreats
- bot does not cast ability on cooldown
- bot attacks visible low-health enemy
- objective-priority bot moves toward objective
- bot input values are clamped
- bot-only match finishes

## Debug output

Each bot decision may emit optional debug fields:

```json
{
  "bot_id": "bot_01",
  "objective": "capture_objective",
  "target_entity_id": 1002,
  "ability_slot": "ability_1",
  "score": 0.82,
  "reason": "enemy_low_health_in_range"
}
```

Do not spam production logs. Enable detailed bot logs only in debug/soak commands.
