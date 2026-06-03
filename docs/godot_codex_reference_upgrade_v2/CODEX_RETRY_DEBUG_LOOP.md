# Codex Retry and Debug Loop

Codex must not stop after the first failed run.

Use this loop for every major command:

```text
change -> run -> inspect output -> fix -> rerun
```

Repeat until the check passes or the remaining blocker is external to the repository.

Required checks include content validation, protocol checks, bot-soak, tests, and a playable menu-to-match-to-result verification path.

The final report must include a retry log that lists each failed command, the fix applied, and the rerun result.
