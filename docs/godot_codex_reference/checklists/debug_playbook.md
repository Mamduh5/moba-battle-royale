# Debug Playbook

## Before debugging

- Record build version.
- Record protocol version.
- Record content version.
- Capture match ID.
- Capture player ID.
- Save client log.
- Save server log.
- Save replay file when available.

## Movement bug

Check input frame, server movement validation, collision, status effects, server correction, and client smoothing.

## Ability bug

Check ability data, request payload, server rejection reason, cooldown/resource state, target validation, and combat event output.

## Network bug

Check handshake, version compatibility, token validation, RTT, packet loss, snapshot delay, input ack, and reconnect state.

## Backend bug

Check Nakama session, storage permissions, RPC name, match ticket, match token, result submission, and idempotency key.

## Bot bug

Check bot perception, current goal, path target, ability score, invalidated plan reason, and generated input commands.
