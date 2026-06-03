# Stack Decisions

## Engine

Use Godot 4.x. Pin the exact Godot minor version in project documentation and CI once the repository is created. Keep the project compatible with the pinned version until a deliberate upgrade task is opened.

## Language

Use typed GDScript as the default language. Every public method in production gameplay code must declare argument and return types. Use explicit class names with `class_name` only for reusable systems that need project-wide access.

Use C# only when a specific subsystem benefits from C# tooling, external packages, or stronger compile-time guarantees. Do not mix GDScript and C# casually inside one gameplay feature.

## Multiplayer backend

Use Nakama for accounts, matchmaking, social systems, leaderboards, storage, inventory metadata, live configuration, and analytics hooks.

Use Godot headless dedicated servers for real-time match simulation. Do not place combat resolution in the client. Do not duplicate combat truth inside Nakama and the Godot match server.

## Network transport

Use Godot ENet for native desktop/mobile builds where allowed. Keep the network layer abstract enough to support WebSocket transport if a web build becomes a product requirement.

## Content data

Use JSON or Godot resources for data-driven content. Prefer JSON for externally reviewable balance/content data and schemas. Prefer `.tres` resources only when tight Godot editor integration is more valuable than external tooling.

## Tooling

Use Godot editor for scenes, UI layout, collisions, animations, imports, and export presets. Use VS Code or another code editor for scripts, schemas, tests, and documentation. Use Git as the source of truth.
