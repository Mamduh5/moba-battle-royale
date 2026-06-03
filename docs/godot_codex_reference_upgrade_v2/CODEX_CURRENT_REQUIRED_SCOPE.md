# Codex Current Required Scope

This file is the current source of truth for required game scope.

If another doc says only 3v3 Team Arena is required, this file overrides that older wording.

## Required modes

The complete game must include both modes:

```text
3v3_team_arena
25_player_deathmatch
```

## 3v3 Team Arena

Required behavior:

- team-based 3v3 match,
- human players allowed from 1 to 6,
- missing slots filled with bots,
- team score determines victory,
- team balancing is server-owned,
- bots use the same `InputFrame` path as humans.

## 25 Player Deathmatch

Required behavior:

- free-for-all deathmatch,
- no teams,
- human players allowed from 1 to 25,
- missing slots filled with bots,
- every participant is hostile to every other participant,
- individual score and rank determine winner,
- server owns scoring, deaths, respawns, bot fill, and final ranking,
- bots use the same `InputFrame` path as humans.

## Required mode selection

The player-facing game must expose mode selection for both:

```text
3v3 Team Arena
25 Player Deathmatch
```

A default quick-start option may exist, but both modes must remain playable.

## Required automated checks

Codex must attempt checks for both modes:

```text
bot-soak --mode 3v3_team_arena --matches 3
bot-soak --mode 25_player_deathmatch --participants 25 --matches 3
```

If the exact command names differ, Codex must run equivalent checks and report the mapping.

## Completion implication

The complete-game target is not met if only 3v3 Team Arena works. Deathmatch must be implemented as a playable mode, not just as a JSON entry.
