# Asset Pipeline

## Asset ownership

Art, audio, VFX, UI images, animations, and imported resources are content assets. Gameplay truth must not depend on visual-only files.

## Import discipline

Use consistent folder structure:

```text
assets/
  source/
  imported/
  sprites/
  ui/
  vfx/
  audio/
  fonts/
```

Keep source art where licensing allows. Document external asset licenses.

## Presentation keys

Gameplay data references presentation keys, not raw scene paths scattered in code. Example:

```json
{
  "presentation_key": "ability_fire_orb"
}
```

A presentation registry maps keys to icons, VFX, SFX, animations, and UI strings.

## Missing asset fallback

Missing presentation keys must fail validation for production content. During local development, fallback visuals may appear only with visible debug warnings.

## Animation

Server simulation does not depend on animation timing except for explicitly authored gameplay timings in ability data. Visual animation can anticipate and follow server events but cannot decide hits.

## Localization

Display names and descriptions use localization keys. Do not put user-facing strings directly in hero or ability logic.
