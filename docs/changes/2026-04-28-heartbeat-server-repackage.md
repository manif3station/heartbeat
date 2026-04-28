# 2026-04-28 heartbeat.server repackaging

## Summary

The loose `skills/server/cli/connected` checker was repackaged into a proper nested heartbeat command with a testable module and a documented JSON contract.

## What Changed

- added `lib/Heartbeat/Server/Connected.pm`
- kept the nested CLI entrypoint at `skills/server/cli/connected`
- changed the command output from ad hoc human text to JSON suitable for DD usage and collector wiring
- documented root-level collector examples for user-owned host and port checks
- verified reachable, unreachable, DNS-failure, and usage-error flows in Docker with 100% coverage

## Why

The raw script was not yet part of the heartbeat skill contract. It needed a stable output shape, release packaging, test coverage, and documentation so users can rely on it as a DD nested command.
