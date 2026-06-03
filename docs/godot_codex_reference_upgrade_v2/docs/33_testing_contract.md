# 33 - Testing Contract

Testing must protect architecture boundaries, not only individual functions.

## Test categories

### Unit tests

Target pure shared systems:

```text
ContentValidator
NetworkCodec
InputFrame
SimulationState
MovementMotor
DamageResolver
AbilityRuntime
CooldownTracker
VictoryResolver
BotAbilityScorer
```

### Integration tests

Target system flow without real sockets first:

```text
SimulationWorld 10,000 ticks
MatchRoom bot-only match
Player input -> ability -> damage -> death -> score
Objective capture -> score -> victory
```

### Protocol tests

Target encode/decode and validation:

```text
client_hello
join_match
player_input
world_snapshot
correction
match_finished
```

### Server smoke tests

Boot server, run room, shut down.

### Bot soak tests

Repeated bot matches with assertions:

- no crash
- no NaN positions
- no entity leaks
- match reaches valid finish
- no accepted invalid casts

### Backend contract tests

For Nakama modules:

- profile read
- loadout save
- matchmaking ticket
- token issue
- result submit
- duplicate result rejected
- client result submit rejected

## Required first tests

Codex must prioritize these tests early:

```text
tests/unit/test_input_frame.gd
tests/unit/test_content_validator.gd
tests/unit/test_network_codec.gd
tests/unit/test_damage_resolver.gd
tests/unit/test_ability_runtime.gd
tests/integration/test_simulation_world_ticks.gd
tests/integration/test_match_room_bot_only.gd
tests/protocol/test_protocol_examples.gd
```

## Pass/fail rules

A test command must return non-zero on failure. Printing a failure is not enough.

## Test data rule

Test fixtures live under:

```text
tests/fixtures/
```

Do not use production content fixtures for edge-case tests unless the test explicitly validates production content.

## Required assertions for gameplay tests

Include assertions for:

- health cannot go below zero unless the data model intentionally allows overkill tracking
- dead entities cannot cast abilities
- cooldown rejects repeated cast
- friendly fire follows mode config
- respawn event occurs after respawn delay
- score increments once per kill/objective event
- victory event emits once

## CI gate

A PR touching shared simulation, server, network, content, or Nakama code must run:

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd validate-content
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd run-tests --suite all
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd protocol-check
```

A PR touching bots or match flow must additionally run:

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd bot-soak --matches 5 --bots 6
```
