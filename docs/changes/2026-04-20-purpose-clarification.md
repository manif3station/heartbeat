# 2026-04-20 Purpose Clarification

## Change Type

Documentation correction

## What Changed

- corrected the docs to describe `heartbeat` as an operational DD heartbeat skill
- removed the implication that the skill exists mainly for testing
- updated the README payload example to match the current implementation output

## Why

`heartbeat` is meant to help users see whether DD, its collector loop, and related status surfaces are still running. The documentation should describe that operational role directly.

## Implementation Alignment

The current implementation still:

- runs through `dashboard heartbeat.check-dd`
- emits a short JSON payload with `now`
- feeds that value into the configured collector indicator template
