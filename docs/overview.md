# heartbeat Overview

## Summary

`heartbeat` is a minimal DD skill that provides an operational heartbeat signal through a skill-owned collector and prompt/indicator integration.

## User Value

It gives users a lightweight way to confirm that:

- DD is still executing the skill collector loop
- the skill command still runs
- prompt or indicator rendering can still react to collector output
- DD still has live status signal flowing through this skill

## Current Features

- `dashboard heartbeat.check-dd` emits a JSON payload with `now`
- `config/config.json` declares a `check-dd` collector
- the collector indicator icon template uses `❤️[% now %]`
- the skill is intended as an operational heartbeat, not a testing-only skill
