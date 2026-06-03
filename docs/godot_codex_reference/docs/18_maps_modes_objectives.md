# Maps, Modes, and Objectives

## Mode architecture

A mode is a ruleset. It declares:

- team size
- win condition
- match phases
- spawn rules
- respawn rules
- objective modules
- bot-fill policy
- ranked eligibility
- surrender policy
- reward category

Mode code uses generic objective modules where possible.

## Map architecture

A map declares:

- spawn points
- collision/nav regions
- objective anchors
- lane paths if applicable
- jungle camps if applicable
- tower/base positions if applicable
- bot hints
- camera bounds
- minimap presentation keys
- fog/visibility zones if used

## Team arena

Win by score or time. Supports 2v2 and 3v3. Suitable for ranked and casual. Core systems: death, respawn, score, overtime if tied.

## Capture objective

Teams contest one or more capture zones. Capture state is server-owned. The client displays progress bars and zone indicators from snapshots.

## MOBA-lite lane mode

Systems:

- minion waves
- towers
- base/core objective
- jungle camps
- neutral objective
- lane pathing
- death/respawn scaling

Do not implement lane mode as a separate game. It uses the same entity, ability, damage, objective, bot, and networking systems.

## Eternal-Return-like survival mode extension

If survival arena is added, use the same architecture:

- larger map
- loot/spawn tables
- shrinking danger zones
- temporary crafting/loadout systems
- solo or team rules
- objective escalation

Persistent economy and ranked rewards still flow through backend validation.

## Map validation

Map validation checks:

- spawn points exist for all teams
- no spawn inside collision
- nav regions connect required routes
- objective anchors reference valid modules
- bot hints are present
- camera bounds exist
- minimap metadata exists
- map supports selected modes
