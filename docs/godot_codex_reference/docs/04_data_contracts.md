# Data Contracts

## Data-first content

All hero, ability, item, status effect, map, and mode definitions live in `content/`. Runtime code loads validated data through `ContentRegistry`.

## File layout

```text
content/
  heroes/
    hero_knight.json
    hero_mage.json
  abilities/
    slash_arc.json
    fire_orb.json
  status_effects/
    stun_short.json
    burn_basic.json
  items/
  maps/
  modes/
  balance/
```

## Validation

Run validation before gameplay tests and before export. Validation fails on:

- Missing required fields.
- Unknown IDs.
- Duplicate IDs.
- Invalid numeric ranges.
- Ability references to missing effects.
- Hero references to missing ability IDs.
- Presentation keys without safe fallback.
- Server behavior IDs not registered.
- Client-only fields inside server-only definitions.

## Versioning

Each content file includes:

- `schema_version`
- `content_version`
- `id`
- `last_balance_note`

The match server and client must agree on content version before match admission. The server rejects clients with incompatible content manifests.

## Manifest

Generate a content manifest:

```json
{
  "schema_version": "1.0.0",
  "content_version": "season_001_patch_001",
  "files": [
    {"path": "content/heroes/hero_knight.json", "sha256": "..."}
  ]
}
```

The client ships with a manifest. The server validates the manifest hash during connect. Live tuning may override selected numeric values only through server-approved live config.

## Naming

Use stable snake_case IDs:

- `hero_knight`
- `ability_fire_orb`
- `status_burn_basic`
- `mode_capture_core`
- `map_sunken_arena`

Never use display names as IDs.
