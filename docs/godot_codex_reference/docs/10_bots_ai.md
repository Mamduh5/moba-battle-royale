# Bots and AI

## Bot principle

Bots are production match participants. They use the same command path as human players. A bot brain produces intent; the server validates and resolves the intent.

## Bot architecture

```text
BotDirector
  BotBrain
    Perception
    Blackboard
    TacticalScorer
    NavigationPlanner
    AbilityPlanner
    TeamCoordinator
    InputEmitter
```

## Perception

Perception reads server-authoritative state. It produces a filtered tactical view:

- visible enemies
- visible allies
- nearby objectives
- projectiles/zones to avoid
- current health/resource state
- cooldown state
- recent damage sources
- map danger areas
- team calls

Bots do not read hidden enemy state unless difficulty mode explicitly grants scouting cheats for training/custom games. Ranked/casual bot-fill should avoid hidden-state cheating.

## Decision loop

Bots do not make heavy decisions every server tick. Use configurable decision intervals:

- easy: 5 to 8 decisions per second
- normal: 8 to 12 decisions per second
- hard: 12 to 20 decisions per second

Movement input can update more frequently using the current plan.

## Behavior layers

Use utility scoring with state-machine execution.

Utility goals:

- survive
- secure kill
- assist ally
- contest objective
- retreat
- farm/minion clear
- defend base/tower
- regroup
- chase
- zone enemy

The highest safe goal selects an action plan. The state machine executes the chosen plan until invalidated.

## Ability use

Ability planner evaluates:

- target value
- hit probability
- cooldown value
- resource cost
- danger after cast
- objective timing
- ally setup
- enemy escape tools

Bots emit the same `AbilityCastRequest` as players.

## Navigation

Use map navigation data. For 2D arenas, support:

- direct steering
- obstacle avoidance
- tactical anchor points
- retreat points
- objective approach paths
- lane paths
- jungle routes

Map data must include bot hints:

- danger zones
- objective zones
- choke points
- safe retreat anchors
- preferred engagement ranges

## Difficulty data

Difficulty changes:

- reaction delay
- aim error
- target priority accuracy
- retreat threshold
- objective priority
- team coordination frequency
- prediction of enemy movement
- pathing smoothness

Difficulty must not bypass server validation.

## Bot testing

Bot-vs-bot tests must run headless. Required reports:

- match completion rate
- average match length
- stuck bot count
- objective participation
- ability usage rate
- death loops
- server performance
- error logs
