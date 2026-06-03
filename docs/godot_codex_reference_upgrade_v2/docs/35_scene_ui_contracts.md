# 35 - Scene and UI Contracts

Use Godot editor for composition, but keep rules reviewable in scripts.

## Required scenes

```text
scenes/client/ClientRoot.tscn
scenes/client/MatchScene.tscn
scenes/server/ServerRoot.tscn
scenes/prefabs/HeroActor.tscn
scenes/prefabs/ProjectileActor.tscn
scenes/prefabs/ObjectiveActor.tscn
scenes/ui/HUD.tscn
scenes/ui/MainMenu.tscn
```

## ClientRoot

Responsibilities:

- Own top-level client state.
- Initialize GameConfig and ContentDB.
- Route between menu, matchmaking, match, result.
- Never run authoritative simulation.

## MatchScene

Responsibilities:

- Instantiate camera, world presentation root, HUD, input sampler, match client.
- Bind snapshots to presentation.
- Display debug overlay.

## HeroActor

Presentation only.

Allowed:

- animation
- sprite/model orientation
- local VFX anchors
- health bar anchor
- selection ring

Forbidden:

- authoritative health mutation
- damage calculation
- cooldown calculation
- score changes

## HUD

HUD reads state from a client facade, not directly from server simulation classes.

Required elements:

```text
health bar
ability buttons
cooldown masks
score/timer
connection indicator
respawn timer
debug overlay toggle
```

## Mobile controls

Mobile controls produce the same `InputFrame` as keyboard/mouse.

Required mobile inputs:

```text
left joystick = movement
right drag / aim area = aim
basic attack button
ability 1 button
ability 2 button
ultimate button
interact button if mode uses it
```

## UI signal rule

UI button signals call client input intent methods only.

Allowed:

```gdscript
input_adapter.set_button_pressed("ability_1", true)
```

Forbidden:

```gdscript
DamageResolver.resolve_damage(...)
CooldownTracker.reset(...)
ScoreService.add_score(...)
```

## Scene editing by Codex

Codex may edit `.tscn` files only when:

- the change is simple and reviewable
- no binary resources are embedded
- node paths are preserved or migrated carefully
- scene still opens in Godot

Prefer scripts and data files for Codex tasks. Use the editor for layout-heavy UI work.
