# SOW-005

## Title

Gate the `heartbeat` skill.

## Objective

Turn the existing `heartbeat` script and config into a fully documented, tested, covered, committed, and pushed DD skill.

## Deliverables

- skill-local version and changelog files
- skill-local docs and ticket records
- testable implementation module
- Docker-based tests with 100% coverage
- release commit and push

# SOW-006

## Title

Repackage the nested `heartbeat.server` health-check sub-skill.

## Objective

Turn the loose nested `skills/server` checker into a proper heartbeat nested command with a stable JSON contract, Docker tests, full documentation, and a release push.

## Deliverables

- nested command packaging for `heartbeat.server.connected`
- testable module for connection checks and CLI dispatch
- Docker-based tests with 100% coverage across the heartbeat skill modules
- updated README, docs, changelog, and ticket records
- release commit and push
