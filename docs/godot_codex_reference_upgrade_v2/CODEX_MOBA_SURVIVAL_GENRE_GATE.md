# Codex MOBA Survival Genre Gate

This project is not asking for a classic lane/tower MOBA and not asking for a tiny arena shooter.

The target is a MOBA Survival game: MOBA-style hero control and ability combat inside a battle-royale/survival-style map structure.

## Genre target

Build a game that feels closer to:

```text
mobile MOBA hero controls + battle-royale/survival map flow
```

Do not build:

```text
classic 3-lane MOBA clone
lane/tower/base-only game
small tank arena
single-screen deathmatch box
bullet hell circle fight
technical combat sandbox
```

## Core control identity

The player controls one hero directly.

The hero must have:

- movement that feels like a mobile MOBA hero,
- clear facing/aim direction,
- 2 normal skills,
- 1 ultimate skill,
- cooldowns,
- visible cast ranges/skill indicators where feasible,
- readable hit/impact feedback,
- meaningful positioning and escape/chase decisions.

The skill kit matters more than lane structure.

## MOBA part of the identity

The game must feel MOBA-like through:

- hero roles or distinct combat identities,
- 3-skill combat kit,
- cooldown/timing decisions,
- skill shots or target/area abilities,
- local-player-focused camera,
- readable health/cooldown HUD,
- tactical fight commitment and disengage windows,
- team/friend cooperation where relevant,
- map objectives or camps that create reasons to move.

It does not need classic MOBA lanes, towers, inhibitors, minion waves, or base cores unless Codex can add them without harming the survival map structure.

## Survival / battle-royale part of the identity

The map and match flow must feel survival/BR-like:

- large scrolling map, not a single-screen arena,
- distributed spawn points,
- offscreen enemies,
- fog-of-war or limited awareness where feasible,
- minimap/radar or directional awareness indicator,
- pickups, camps, resource nodes, shrines, chests, or neutral monsters,
- safe-zone/danger-zone pressure or equivalent shrinking combat area,
- space to rotate, chase, retreat, hide, flank, and reposition,
- match pacing that moves players from exploration/farming into fights,
- final-circle/final-zone or endgame pressure.

A player should not see all opponents at once at match start.

## Hard fail rules

The genre gate fails if:

- all 25 deathmatch participants fit comfortably on one screen,
- the map is a small rectangular combat box,
- the 25-player mode has no exploration, rotation, offscreen threats, or zone pressure,
- the game looks like tanks or generic tokens shooting in a room,
- hero abilities feel like plain bullets with labels,
- the player has no reason to move around the map except chasing the nearest enemy,
- there are no pickups/camps/objectives/resources or survival pressure,
- the camera does not follow the local player through a larger map,
- the match has no escalation from early positioning to midgame fights to endgame pressure.

## 3v3 mode target

The 3v3 mode should not be a classic lane/tower MOBA and should not be a tiny arena brawl.

It should be a squad survival objective mode:

- 3 humans/bots per side,
- large enough map for rotations and flanks,
- team score/objective pressure,
- camps, shrines, crystals, supply points, or neutral monsters,
- safe-zone/danger pressure if appropriate,
- bot teammates and enemies that rotate toward objectives,
- friend-capable play with bot fill,
- match result by objective score, timer, eliminations, or final zone condition.

## 25-player mode target

The 25-player mode must feel like a survival/BR-style free-for-all with MOBA controls.

Required behavior:

- 25 participants maximum,
- humans from 1 to 25,
- bot fill for missing slots,
- no teams by default,
- large scrolling map,
- distributed spawns,
- resource/objective points,
- safe-zone/danger-zone pressure or equivalent convergence mechanic,
- individual ranking,
- final result by survival rank, kills/score, timer, or final-zone victory.

The 25-player mode is not complete if it is only a crowded combat arena.

## Map size and camera rules

The playable map must be larger than the viewport.

At 1280x720 and 1920x1080, the local player should see only part of the world.

Required implications:

- camera follows the local player,
- enemies can be offscreen,
- map traversal matters,
- radar/minimap/directional threat indicators help awareness,
- screenshots must show that the map extends beyond the current view.

## Bot behavior requirement

Bots must not only run at the nearest enemy.

Bots should be able to:

- explore or rotate,
- seek pickups/resources/camps/objectives,
- avoid danger zone,
- engage when advantaged,
- retreat when weak,
- converge as the safe zone shrinks,
- use skill kits in combat.

## Visual/product requirement

The result must not look like a tank game or token battle.

Heroes should look like heroes, not vehicles or dots:

- readable body silhouettes,
- weapon/magic/role identity,
- cast effects,
- ability indicators,
- local-player emphasis,
- enemy threat readability,
- survival-map landmarks.

## Acceptance language

Codex must report this gate separately:

```text
MOBA Survival genre gate:
- map larger than viewport: pass/fail
- all enemies visible at start: yes/no
- 3-skill hero kit: pass/fail
- survival/BR map flow: pass/fail
- objectives/resources/camps: pass/fail
- safe-zone/danger pressure: pass/fail
- bot rotation/objective behavior: pass/fail
- not a tiny arena/tank game: pass/fail
```

Do not report `Complete` if this gate fails.
