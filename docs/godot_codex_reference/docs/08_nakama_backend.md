# Nakama Backend

## Responsibility boundary

Nakama owns player identity and meta systems. The Godot match server owns combat simulation. Keep the boundary clear.

Nakama responsibilities:

- authentication
- sessions
- player profiles
- storage objects
- inventory metadata
- currencies and reward ledgers
- matchmaking tickets
- parties/lobbies
- friends and chat
- leaderboards and ranked seasons
- live config and feature flags
- match result validation/persistence

Godot match server responsibilities:

- entity simulation
- movement validation
- ability/cooldown validation
- combat resolution
- objective scoring
- bot inputs
- snapshots
- replay/event logs
- authoritative match result generation

## Local development

Use Docker Compose for Nakama plus CockroachDB or PostgreSQL. Store local credentials in ignored environment files. Do not commit production secrets.

## Backend modules

Create backend runtime modules for:

- match ticket validation
- match allocation payload creation
- signed match token generation
- match result validation
- reward calculation
- season/rating updates
- live config publication
- moderation hooks

## Match token

The match token must include:

- player ID
- session ID
- match ID
- roster slot
- team ID
- role: player, spectator, admin
- expiration
- build/content constraints
- signature

The match server validates token before admission.

## Storage model

Recommended storage collections:

- `profile`: display name, avatar, region, settings metadata
- `inventory`: owned heroes, skins, cosmetics, boosts
- `progression`: XP, level, unlock tracks
- `ranked`: MMR, visible rank, season stats
- `loadouts`: hero loadouts, cosmetic choices
- `missions`: daily/weekly mission progress
- `moderation`: penalties, restrictions, flags

## Match result packet

A match result includes:

- match ID
- server ID
- ruleset version
- content version
- start and end time
- roster
- winner/team result
- score timeline summary
- player stats
- bot stats
- disconnects/reconnects
- suspicious input summary
- replay reference
- server signature

Nakama validates the packet before applying progression.
