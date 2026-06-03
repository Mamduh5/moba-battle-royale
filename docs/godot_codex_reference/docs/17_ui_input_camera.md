# UI, Input, and Camera

## Input model

Input is converted into gameplay intent. The client emits intent; the server decides outcomes.

Supported mobile controls:

- virtual joystick movement
- aim drag for abilities
- tap-to-cast quick abilities
- manual aim release
- cancel cast area
- attack button
- ultimate button
- item/action button
- ping wheel
- scoreboard toggle

Desktop controls may map to keyboard/mouse for development and PC release.

## Input abstraction

Create `InputIntentProvider` implementations:

- `MobileInputIntentProvider`
- `DesktopInputIntentProvider`
- `BotInputIntentProvider`
- `ReplayInputIntentProvider`

All providers output the same command shape.

## HUD

HUD displays server-authoritative state:

- health/resources
- ability cooldowns
- team score
- match timer
- objective state
- status effects
- respawn timer
- ping/network warning
- kill feed
- minimap if mode uses one

HUD scripts must not mutate combat state.

## Camera

Camera follows local player with smoothing. Camera can shift toward aim direction for skillshots. Spectator mode supports free cam or target follow.

Camera must not affect server state.

## UI scene policy

Use Godot editor for complex UI layout. Code-agent edits may adjust bindings, signals, constants, and simple node paths, but must avoid large blind changes to visual layout.

## Accessibility

Support:

- adjustable joystick size and opacity
- colorblind-safe team indicators
- scalable UI text
- reduced screen shake
- simplified skill indicators
- audio cues for critical events
