# heartbeat

## Description

`heartbeat` is a Developer Dashboard skill for testing and using the skill collector path that surfaces a live heartbeat in the prompt/indicator flow.

## Value

It gives the user a small installable skill that demonstrates:

- skill installation and removal
- skill CLI dispatch
- skill collector configuration through `config/config.json`
- prompt or indicator visibility when the DD collector loop is running

## Problem It Solves

A new DD user may want a minimal skill that proves the dashboard collector and prompt integration are active without introducing a larger feature.

## What It Does To Solve It

`heartbeat` emits a tiny JSON payload with a `now` value and wires that payload into a skill collector named `check-dd`. The collector is configured to run `dashboard heartbeat.check-dd` every 5 seconds and exposes an indicator icon template.

## Developer Dashboard Feature Added

This skill adds:

- the dotted command usage `dashboard heartbeat.check-dd`
- a skill collector declared in `config/config.json`
- a prompt/indicator heartbeat signal while DD is running its collector loop

## Layout

- `cli/check-dd` skill CLI entrypoint
- `config/config.json` collector declaration
- `docs/` skill-local documentation
- `lib/Heartbeat/CheckDD.pm` implementation module
- `t/` skill-local tests
- `.env` skill-local version metadata
- `Changes` skill-local changelog

## Installation

Install the skill through Developer Dashboard from a git repository:

```bash
dashboard skills install <git-url-to-heartbeat-skill>
```

Example:

```bash
dashboard skills install git@github.mf:manif3station/heartbeat.git
```

## CLI Usage

Direct local development:

```bash
perl cli/check-dd
```

Installed DD usage:

```bash
dashboard heartbeat.check-dd
```

Expected output shape:

```json
{"now":1234567890}
```

The exact number changes each run.

## Prompt And Indicator Usage

Once the skill is installed and DD is running its managed collectors, the collector declared in `config/config.json` contributes an indicator entry using:

```text
❤️[% now %]
```

This is intended as a heartbeat signal that shows DD is still running the collector path.

## Practical Examples

Normal case, install the skill:

```bash
dashboard skills install git@github.mf:manif3station/heartbeat.git
```

Normal case, run the CLI command directly through DD:

```bash
dashboard heartbeat.check-dd
```

Normal case, inspect the skill metadata:

```bash
dashboard skills usage heartbeat
```

Normal case, remove the skill after testing:

```bash
dashboard skills uninstall heartbeat
```

## Edge Cases

- if the skill is not installed, `dashboard heartbeat.check-dd` will not dispatch
- if DD collectors are not running, the prompt indicator will not refresh
- if the skill is disabled, the collector should drop out of the DD collector fleet

## Documentation

See:

- `docs/overview.md`
- `docs/usage.md`
- `docs/changes/2026-04-20-gating.md`

