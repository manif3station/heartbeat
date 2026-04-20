# heartbeat

## Description

`heartbeat` is a Developer Dashboard skill for checking whether DD is still alive through its skill collector path. Once installed, it contributes a collector-backed heartbeat signal that can appear in the prompt or indicator flow and helps show that DD and its managed collectors are still running.

## Value

It gives the user a small operational skill that helps confirm:

- DD skill collectors are still running
- prompt or indicator rendering is still receiving collector values
- DD still has an active heartbeat path through the skill command and collector loop
- the DD web-facing status flow still has fresh collector-backed signal data to render

## Problem It Solves

When DD is expected to stay alive in the background, it is useful to have a simple skill-owned heartbeat signal that can show whether the collector loop, prompt integration, and related DD status surface are still active.

## What It Does To Solve It

`heartbeat` emits a tiny JSON payload with a `now` value and wires that payload into a skill collector named `check-dd`. The collector is configured to run `dashboard heartbeat.check-dd` every 5 seconds and exposes an indicator icon template.

## Developer Dashboard Feature Added

This skill adds:

- the dotted command usage `dashboard heartbeat.check-dd`
- a skill collector declared in `config/config.json`
- a prompt or indicator heartbeat signal while DD is running its collector loop

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
{"now":45}
```

The exact number changes each run. The current implementation emits the last two reversed digits from the epoch-derived value, so the payload is intentionally short.

## Prompt And Indicator Usage

Once the skill is installed and DD is running its managed collectors, the collector declared in `config/config.json` contributes an indicator entry using:

```text
❤️[% now %]
```

This is intended as a heartbeat signal that shows DD is still running the collector path and still has live collector-backed status data.

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

Normal case, remove the skill:

```bash
dashboard skills uninstall heartbeat
```

## Edge Cases

- if the skill is not installed, `dashboard heartbeat.check-dd` will not dispatch
- if DD collectors are not running, the prompt indicator will not refresh
- if DD stops updating web-visible collector state, the heartbeat signal will become stale
- if the skill is disabled, the collector should drop out of the DD collector fleet

## Documentation

See:

- `docs/overview.md`
- `docs/usage.md`
- `docs/changes/2026-04-20-gating.md`
- `docs/changes/2026-04-20-purpose-clarification.md`
