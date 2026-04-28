# heartbeat

## Description

`heartbeat` is a Developer Dashboard skill for checking whether DD is still alive through its skill collector path and for probing whether a user-chosen server endpoint is still reachable. Once installed, it contributes a collector-backed heartbeat signal and a nested server-check command that can be wired into prompt indicators.

## Value

It gives the user a small operational skill that helps confirm:

- DD skill collectors are still running
- prompt or indicator rendering is still receiving collector values
- DD still has an active heartbeat path through the skill command and collector loop
- the DD web-facing status flow still has fresh collector-backed signal data to render
- user-chosen SSH, TCP, or service endpoints are still reachable before they start a task that depends on them

## Problem It Solves

When DD is expected to stay alive in the background, it is useful to have a simple skill-owned heartbeat signal that can show whether the collector loop, prompt integration, and related DD status surface are still active. It is also useful to have a quick nested command that checks whether a target host and port are reachable, especially for flows such as SSH access checks or "is that server still there?" confirmation before the user loses time.

## What It Does To Solve It

`heartbeat` emits a tiny JSON payload with a `now` value and wires that payload into a skill collector named `check-dd`. The collector is configured to run `dashboard heartbeat.check-dd` every 5 seconds and exposes an indicator icon template. The skill also exposes a nested command, `dashboard heartbeat.server.connected`, that checks a supplied host and port and returns JSON with `host`, `port`, `status`, and `reachable`.

## Developer Dashboard Feature Added

This skill adds:

- the dotted command usage `dashboard heartbeat.check-dd`
- the nested dotted command usage `dashboard heartbeat.server.connected`
- a skill collector declared in `config/config.json`
- a prompt or indicator heartbeat signal while DD is running its collector loop
- a reusable server reachability command that users can wire into their own root collector config

## Layout

- `cli/check-dd` skill CLI entrypoint
- `skills/server/cli/connected` nested server-check entrypoint
- `config/config.json` collector declaration
- `docs/` skill-local documentation
- `lib/Heartbeat/CheckDD.pm` implementation module
- `lib/Heartbeat/Server/Connected.pm` nested server-check implementation
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

Installed DD usage for the nested server checker:

```bash
dashboard heartbeat.server.connected ssh-gateway.example.test 22
```

Example success payload:

```json
{"host":"ssh-gateway.example.test","port":22,"status":"up","reachable":1}
```

Example unreachable payload:

```json
{"host":"ssh-gateway.example.test","port":22,"status":"down","reachable":0}
```

Example DNS failure payload:

```json
{"host":"missing-host.invalid","port":22,"status":"dns_error","reachable":0}
```

Exit behavior for `heartbeat.server.connected`:

- `0` when the target is reachable
- `1` when the target is not reachable or when required arguments are missing
- `2` when the hostname cannot be resolved

## Prompt And Indicator Usage

Once the skill is installed and DD is running its managed collectors, the collector declared in `config/config.json` contributes an indicator entry using:

```text
❤️[% now %]
```

This is intended as a heartbeat signal that shows DD is still running the collector path and still has live collector-backed status data.

The nested `server` check is not shipped as a default collector because the host, port, and indicator text are user-specific. Add those collectors in the root DD config yourself.

Example snippet for `~/.developer-dashboard/config/config.json`:

```json
{
  "collectors": [
    {
      "command": "dashboard heartbeat.server.connected 203.0.113.24 22",
      "cwd": "home",
      "indicator": {
        "icon": "LAN🔗"
      },
      "interval": 5,
      "name": "office-ssh-reachable",
      "rotations": {
        "lines": 10
      }
    },
    {
      "command": "dashboard heartbeat.server.connected 198.51.100.42 22",
      "cwd": "home",
      "indicator": {
        "icon": "VPN🔗"
      },
      "interval": 5,
      "name": "remote-ssh-reachable",
      "rotations": {
        "lines": 10
      }
    }
  ]
}
```

Those targets are made-up examples. Replace them with your own server names or IP addresses.

## Practical Examples

Normal case, install the skill:

```bash
dashboard skills install git@github.mf:manif3station/heartbeat.git
```

Normal case, run the CLI command directly through DD:

```bash
dashboard heartbeat.check-dd
```

Normal case, check whether an SSH endpoint is reachable:

```bash
dashboard heartbeat.server.connected ssh-gateway.example.test 22
```

Normal case, check whether a web service port is reachable:

```bash
dashboard heartbeat.server.connected app-edge.example.test 443
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
- if the skill is not installed, `dashboard heartbeat.server.connected` will not dispatch
- if DD collectors are not running, the prompt indicator will not refresh
- if DD stops updating web-visible collector state, the heartbeat signal will become stale
- if the skill is disabled, the collector should drop out of the DD collector fleet
- if a hostname cannot be resolved, `heartbeat.server.connected` returns `dns_error` and exits `2`
- if a target port is closed or filtered, `heartbeat.server.connected` returns `down` and exits `1`
- if the host argument is omitted, `heartbeat.server.connected` returns a usage JSON payload and exits `1`

## Documentation

See:

- `docs/overview.md`
- `docs/usage.md`
- `docs/changes/2026-04-20-gating.md`
- `docs/changes/2026-04-20-purpose-clarification.md`
- `docs/changes/2026-04-28-heartbeat-server-repackage.md`
