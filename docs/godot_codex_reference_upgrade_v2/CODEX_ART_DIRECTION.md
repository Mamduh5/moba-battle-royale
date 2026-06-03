# Codex Art Direction Contract

The complete game must look intentional and readable, even if Codex uses simple generated shapes, vector-style sprites, or primitive Godot drawing instead of imported art assets.

Do not ship a player-facing game that looks like random debug boxes.

## Visual target

Use this style unless the repository already contains a stronger art direction:

```text
clean top-down arcade arena
high readability
bold silhouettes
flat colors with simple outlines
clear team/player/enemy identity
minimal but polished UI
simple VFX that communicate gameplay instantly
```

The art does not need to be expensive. It must be coherent.

## Minimum art set

The complete game needs visible, player-facing art for:

- 3 playable heroes,
- bot-controlled versions of the heroes,
- projectiles or hit effects for basic attacks,
- 9 ability icons or readable ability buttons,
- 9 ability VFX or clear cast indicators,
- player health bars,
- enemy/bot health bars,
- 3v3 Team Arena scoreboard treatment,
- 25 Player Deathmatch rank/score treatment,
- arena floor,
- arena bounds,
- walls/obstacles,
- spawn points or spawn effects,
- main menu,
- mode select,
- HUD,
- pause menu,
- result screen.

If imported assets are unavailable, create simple procedural/vector assets inside Godot using scenes, polygons, colored shapes, labels, particles, or generated image files.

## Hero readability

The 3 heroes must be visually distinct at gameplay zoom.

Minimum distinction:

```text
Hero 1: sturdy/tank silhouette, broad body, shield/barrier visual language
Hero 2: agile/assassin silhouette, narrow body, dash/slash visual language
Hero 3: ranged/caster silhouette, staff/orb/projectile visual language
```

Each hero needs:

- distinct body shape,
- distinct primary color/accent,
- distinct ability color language,
- readable facing or aim direction,
- readable selection marker for the local player.

Do not make all heroes identical circles with different names only.

## 25-player readability

Deathmatch can contain 25 participants, so visual clarity matters.

Required rules:

- the local player must be unmistakable,
- nearby enemies must be readable without name labels covering the screen,
- far participants may use simplified markers,
- health bars should be compact,
- scoreboard must show top ranks without blocking combat,
- deaths, hits, and ability casts must remain understandable during chaos.

Use visual priority:

```text
local player > immediate threats > projectiles/hazards > low-health enemies > far participants > decorative details
```

## Team Arena readability

For 3v3 Team Arena:

- allies and enemies must be visually different,
- team score must be obvious,
- the local player must still be more visible than allies,
- bot teammates must not look like neutral objects,
- ability effects must not hide score, health, or cooldown information.

## UI style

Use a simple polished HUD:

- readable font sizes,
- consistent spacing,
- visible cooldown states,
- clear health bars,
- clear score/timer/rank area,
- mode-specific labels,
- buttons with hover/pressed/focused states where feasible.

The UI may be minimal, but it must not look like raw engine debug labels scattered across the screen.

## Ability icon and VFX rules

Every ability needs a readable icon or button treatment.

If custom icons are not available, generate consistent symbolic icons:

- basic attack: weapon/bolt/slash symbol,
- mobility: arrow/dash symbol,
- defense: shield/barrier symbol,
- ultimate: larger high-contrast symbol.

Every ability must provide feedback when used:

- cast flash,
- projectile trail,
- area marker,
- impact burst,
- cooldown visual change,
- denied-cast feedback when on cooldown or invalid.

## Map art rules

The arena must show:

- playable floor area,
- wall/obstacle boundaries,
- spawn zones,
- safe bounds,
- optional decorative patterning that does not obscure gameplay.

The same arena may support both required modes if the spawn and scoring logic adapts properly.

## Placeholder language rule

Do not display these words in player-facing UI:

```text
placeholder
mock
prototype
temporary
TODO
unfinished
```

Internal code comments may explain fallback/generated art, but the player-facing game should present itself as a complete small game.

## Acceptance gates

The visual/art target is met when:

- the game can be recognized as a finished small arcade arena game,
- all heroes are visually distinguishable during gameplay,
- abilities have icons/buttons and visible feedback,
- the local player is readable in both 3v3 and 25-player modes,
- score/timer/rank information is readable,
- UI screens have consistent style,
- no required player-facing screen uses raw debug-only presentation.

## If art generation is limited

Use the best available deterministic method:

1. generated PNGs if image tooling exists,
2. Godot-generated textures or polygons,
3. ColorRect/Polygon2D/Line2D/Label-based vector presentation,
4. simple particles or animated scale/alpha effects.

The fallback must still be cohesive and readable.
