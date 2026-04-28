# heartbeat Overview

## Summary

`heartbeat` is a DD operational skill that provides an internal heartbeat signal through a skill-owned collector and also exposes a nested server-reachability command for user-chosen host and port checks.

## User Value

It gives users a lightweight way to confirm that:

- DD is still executing the skill collector loop
- the skill command still runs
- prompt or indicator rendering can still react to collector output
- DD still has live status signal flowing through this skill
- chosen remote endpoints are reachable before the user starts work that depends on them

## Current Features

- `dashboard heartbeat.check-dd` emits a JSON payload with `now`
- `dashboard heartbeat.server.connected <host> [port]` emits JSON describing server reachability
- `config/config.json` declares a `check-dd` collector
- the collector indicator icon template uses `❤️[% now %]`
- the skill is intended as an operational heartbeat, not a testing-only skill
- nested server collectors belong in the root DD `~/.developer-dashboard/config/config.json` because their targets are user-specific
