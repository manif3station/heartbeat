# heartbeat Overview

## Summary

`heartbeat` is a minimal DD skill that demonstrates a skill-owned collector and prompt indicator signal.

## User Value

It gives users a lightweight way to confirm that:

- a skill can be installed cleanly
- a skill CLI command can run
- a skill collector can join DD's managed collector flow
- prompt or indicator rendering can react to collector output

## Current Features

- `dashboard heartbeat.check-dd` emits a JSON payload with `now`
- `config/config.json` declares a `check-dd` collector
- the collector indicator icon template uses `❤️[% now %]`

