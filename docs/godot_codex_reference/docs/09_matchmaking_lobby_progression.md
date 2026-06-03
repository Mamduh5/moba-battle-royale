# Matchmaking, Lobby, and Progression

## Player flow

1. Boot app.
2. Authenticate through Nakama.
3. Fetch player profile and live config.
4. Enter lobby.
5. Select mode, region, and party state.
6. Submit matchmaker ticket.
7. Receive match assignment.
8. Download or verify required content manifest.
9. Connect to match server.
10. Play match.
11. Receive result.
12. Fetch updated profile/rewards/rank.

## Matchmaking parameters

Tickets include:

- player ID
- party ID
- selected mode
- preferred region
- device/platform
- latency bucket
- rating bucket
- role preference if roles exist
- allowed bot-fill policy
- content/build version

## Parties

Party state is backend-owned. The party leader controls queue mode. Party members accept ready checks. Disconnects preserve party membership for a configured timeout.

## Ranked

Ranked mode requires stricter policy:

- verified build version
- stable content version
- reconnect penalty rules
- surrender rules
- bot substitution policy
- MMR/rating update from authoritative result only
- ban/pick support if added later

## Progression

Progression is never granted directly by clients. Rewards come from backend validation of server-signed match results.

Supported progression:

- account XP
- hero mastery
- ranked rating
- battle pass/season track
- mission progress
- currency grants
- cosmetic unlocks

## Live configuration

Live config includes:

- active season ID
- enabled modes
- map rotation
- matchmaking thresholds
- bot-fill limits
- balance overrides approved for server use
- event missions
- store visibility
- maintenance flags

The match server receives only gameplay-relevant live config. The client receives UI and presentation config.
