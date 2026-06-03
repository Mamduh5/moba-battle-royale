# Codex One-Prompt Product Quality Gate

This file exists because the challenge is not to generate a technical scaffold. The challenge is to make a complete small game in one prompt.

A game is not complete if it only passes content, protocol, bot, backend, and smoke tests while still looking or feeling like a raw programmer-art prototype.

## One-prompt rule

Do not split product quality into a later polish pass.

The same prompt must handle:

- gameplay systems,
- UI,
- art direction,
- VFX/readability,
- multiplayer/friend flow,
- backend/local services,
- testing,
- rendered QA,
- debug/retry,
- final quality judgment.

If the game would need another prompt to become visually acceptable, the current prompt has failed the challenge.

## Product-quality definition

The complete game must look like an intentional small arcade game.

It does not need AAA art. It does need:

- composed title/menu screens,
- styled buttons and panels,
- non-default HUD treatment,
- readable ability buttons/icons,
- readable score/rank panels,
- distinct hero silhouettes,
- clear local-player emphasis,
- styled arena floor/walls/spawns/objective areas,
- visible cast/impact/death/respawn feedback,
- readable 25-player deathmatch chaos,
- coherent color palette,
- consistent typography/spacing.

## Hard fail visual descriptions

If a human reviewer would reasonably describe the game as any of these, the product-quality gate fails:

```text
raw Godot controls
default UI
programmer art
just squares and circles
placeholder-looking
pre-prototype
tech demo
movement demo
debug scene
unpolished layout
unreadable HUD
no visual identity
```

Do not call the game complete in that case, even if all automated tests pass.

## Primitive/vector art rule

Primitive/vector drawing is allowed only as an implementation method, not as the final look.

A circle can be part of a hero, but the hero cannot be only a plain circle.
A rectangle can be part of a wall, but the arena cannot feel like only default rectangles.
A default Button can be used internally, but player-facing UI must be themed and composed.

Codex must add styling layers:

- outlines,
- shadows/glows,
- layered shapes,
- silhouettes,
- readable icons,
- hover/pressed states,
- selected/focused states,
- VFX motion or animated feedback,
- panel backgrounds,
- consistent margins and hierarchy.

## Required UI/theme work

The implementation must include a reusable visual system, such as:

```text
client/ui/theme/
client/ui/components/
client/presentation/style/
```

Required elements:

- shared palette constants,
- button style factory or Theme resource,
- panel style factory or Theme resource,
- HUD component styles,
- ability icon/button component,
- scoreboard/ranking component,
- hero marker/local-player component,
- deathmatch top-rank component,
- title/menu layout component.

Do not build all UI as ad-hoc raw labels/buttons inside one main script.

## Required art/game-view work

The game view must include:

- local player marker that is obvious in 3v3 and 25-player deathmatch,
- three hero visual identities beyond color-only differences,
- bot/enemy readability at gameplay zoom,
- ability VFX for each ability family,
- projectile trails or impact effects,
- hit feedback,
- death/respawn feedback,
- arena floor detail that does not obscure combat,
- walls/obstacles with styled edges,
- spawn/objective indicators.

## Required screenshot self-review

After generating screenshots, Codex must review them against this rubric.

For each screenshot, classify:

```text
pass
needs fix
fail
```

Required screenshot categories:

- main menu,
- mode select,
- 3v3 mid-match HUD,
- 3v3 result,
- 25-player deathmatch mid-match HUD,
- 25-player deathmatch result.

For every `needs fix` or `fail`, Codex must patch and recapture before final report.

## Product-quality report requirement

The final report must include:

```text
Product quality review:
- main menu: pass/needs fix/fail + reason
- mode select: pass/needs fix/fail + reason
- 3v3 gameplay view: pass/needs fix/fail + reason
- 3v3 result screen: pass/needs fix/fail + reason
- deathmatch gameplay view: pass/needs fix/fail + reason
- deathmatch result screen: pass/needs fix/fail + reason
- raw/default UI remaining: yes/no + details
- squares/circles-only art remaining: yes/no + details
- final product-quality status: pass/fail
```

If final product-quality status is fail, the game completion status must be incomplete.

## Automated checks are not enough

These alone do not prove product quality:

- `errors: []` from a geometry audit,
- screenshots created but not reviewed,
- content validation passed,
- bot-soak passed,
- backend RPCs passed,
- headless launch passed,
- console logs clean.

They are necessary but not sufficient.

## Single-prompt completion behavior

During the one prompt, Codex must reserve effort for visual/product quality. Do not spend the entire run on backend/testing and then leave UI/art as primitive shapes.

Recommended execution split inside one prompt:

```text
25% inspect current repo and plan integrated fixes
25% implement/fix gameplay, modes, network, backend gaps
30% implement UI/art/VFX/product-quality upgrades
15% run validation, visual QA, screenshots, network/backend checks
5% final fixes and strict gate report
```

This split is guidance, not a reason to stop early. The final product must pass all strict gates.

## Final hard rule

Do not report `Complete` if the best honest description is:

```text
It works technically, but it still looks like a first prototype.
```

That is incomplete for this challenge.
