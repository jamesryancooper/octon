# Release Gates

## Required Gates

- Harness structure validation passes.
- Engine runtime build/tests pass.
- Legacy path banlist and migration CI checks pass.

## Merge Rule

Engine migrations do not merge until all required gates are green and migration evidence is recorded.
