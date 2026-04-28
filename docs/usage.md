# heartbeat Usage

## Install

```bash
dashboard skills install git@github.mf:manif3station/heartbeat.git
```

## CLI

Direct local development:

```bash
perl cli/check-dd
```

Installed DD usage:

```bash
dashboard heartbeat.check-dd
```

Expected result:

- valid JSON is printed
- the JSON contains a numeric `now` value
- the current implementation emits a short truncated value such as `{"now":45}`

Installed DD usage for the nested server checker:

```bash
dashboard heartbeat.server.connected bastion.example.test 22
```

Expected result:

- valid JSON is printed
- the JSON contains `host`, `port`, `status`, and `reachable`
- the command exits `0` for `up`, `1` for `down`, and `2` for `dns_error`

## Prompt And Indicator

The collector is configured in `config/config.json` as:

- name: `check-dd`
- interval: `5`
- command: `dashboard heartbeat.check-dd`

When DD is running collectors, the indicator icon template is:

```text
❤️[% now %]
```

This is meant to help show that DD is still alive through its collector-backed status flow.

The nested `heartbeat.server.connected` feature is a user-configured collector path, not a default shipped collector. Put those entries in your root DD config so you can choose the targets yourself.

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

Those addresses and names are examples only. Replace them with your own targets.

## Uninstall

```bash
dashboard skills uninstall heartbeat
```

## Edge Cases

- if the skill is disabled, DD should stop using its collector
- if DD is not running collectors, the heartbeat indicator will not update
- if DD stops updating status surfaces, the heartbeat value may become stale
- if the skill is uninstalled, DD should no longer dispatch `heartbeat.check-dd`
- if the hostname cannot be resolved, `heartbeat.server.connected` prints `dns_error` JSON and exits `2`
- if the target port is closed, `heartbeat.server.connected` prints `down` JSON and exits `1`
- if the host argument is omitted, `heartbeat.server.connected` prints a usage JSON payload and exits `1`
