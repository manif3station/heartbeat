# Testing

## Policy

- tests run only inside Docker
- the shared test container definition lives at the workspace root
- this skill keeps its test files in `t/`

## Commands

```bash
docker compose -f ~/projects/skills/docker-compose.testing.yml run --rm perl-test bash -lc 'cd /workspace/skills/heartbeat && prove -lr t'
docker compose -f ~/projects/skills/docker-compose.testing.yml run --rm perl-test bash -lc 'cd /workspace/skills/heartbeat && cover -delete && HARNESS_PERL_SWITCHES=-MDevel::Cover prove -lr t && cover -report text -select_re "^lib/" -coverage statement -coverage subroutine'
```

## Latest Verification

- Date: 2026-04-28
- Functional test:
  - `docker compose -f ~/projects/skills/docker-compose.testing.yml run --rm perl-test bash -lc 'cd /workspace/skills/heartbeat && prove -lr t'`
  - Result: pass
- Coverage test:
  - `docker compose -f ~/projects/skills/docker-compose.testing.yml run --rm perl-test bash -lc 'cd /workspace/skills/heartbeat && cover -delete && HARNESS_PERL_SWITCHES=-MDevel::Cover prove -lr t && cover -report text -select_re "^lib/" -coverage statement -coverage subroutine'`
  - Result: pass
  - Coverage: `100.0%` statement and `100.0%` subroutine for `lib/Heartbeat/CheckDD.pm`
  - Coverage: `100.0%` statement and `100.0%` subroutine for `lib/Heartbeat/Server/Connected.pm`
- Installed DD proof:
  - `dashboard heartbeat.check-dd`
  - Result: pass
  - `dashboard heartbeat.server.connected 127.0.0.1 18443`
  - Result: pass, returned JSON status `up`
  - `dashboard heartbeat.server.connected missing-host.invalid 22`
  - Result: pass, returned JSON status `dns_error` and exit `2`
  - `dashboard heartbeat.server.connected`
  - Result: pass, returned JSON status `usage_error` and exit `1`
- Cleanup:
  - `docker compose -f ~/projects/skills/docker-compose.testing.yml run --rm perl-test bash -lc 'rm -rf /workspace/skills/heartbeat/cover_db'`
  - Result: pass
