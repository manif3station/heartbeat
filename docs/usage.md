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

## Uninstall

```bash
dashboard skills uninstall heartbeat
```

## Edge Cases

- if the skill is disabled, DD should stop using its collector
- if DD is not running collectors, the heartbeat indicator will not update
- if DD stops updating status surfaces, the heartbeat value may become stale
- if the skill is uninstalled, DD should no longer dispatch `heartbeat.check-dd`

