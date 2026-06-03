# LAN Friend Transport

The rescue pass adds a concrete line-delimited JSON TCP transport for local friend smoke testing:

- server adapter: `server/network/TcpServerTransport.gd`
- client adapter: `client/network/TcpFriendClient.gd`
- smoke command: `friend-smoke`

Smoke command examples:

```bash
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd friend-smoke --mode 3v3_team_arena --port 24680
godot --headless --path . -s res://server/cli/HeadlessCommandRouter.gd -- --cmd friend-smoke --mode 25_player_deathmatch --port 24681
```

The command starts a localhost TCP server, connects two concrete TCP clients, performs hello/join/input/snapshot/result messaging, then verifies bot fill and match completion. It is a development LAN/local transport path, not a production relay or ranked matchmaking service.
