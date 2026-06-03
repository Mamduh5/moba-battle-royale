# Local Multiplayer and Backend Boundary

Arena Royale keeps gameplay authority in the Godot match room. The local client uses `MatchClient` to send `InputFrame` objects to a `MatchRoom`; snapshots and results come back through the same boundary used by headless commands.

Friend-capable local flow:

1. Host Match creates a local room code.
2. Join Match accepts a room code and starts a local room with a second simulated human session for smoke coverage.
3. The server-owned `MatchRoom` assigns humans, fills all remaining slots with bots, and starts the authoritative simulation.
4. `LocalNakamaAdapter` issues development match tokens and accepts server-submitted results through the Nakama-compatible interface.

The Docker/Nakama files under `infra/nakama/` and `backend/nakama/` are local development scaffolding. Live Nakama execution must still be validated in an environment with Docker and the Nakama Go runtime toolchain.
