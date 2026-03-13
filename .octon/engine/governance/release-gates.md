# Release Gates

## Required Gates

1. Execution-profile governance receipt is present and complete:
   - `Profile Selection Receipt`
   - `Implementation Plan`
   - `Impact Map (code, tests, docs, contracts)`
   - `Compliance Receipt`
   - `Exceptions/Escalations`
2. Semantic release-state gate is valid:
   - `release_state` is derived from semver sources.
   - Pre-1.0 defaults to `change_profile=atomic` unless hard gates require transitional.
   - Pre-1.0 transitional includes complete `transitional_exception_note`.
3. Harness structure validation passes.
4. Agency/workflow/skills validators pass.
5. Legacy path banlist and migration CI checks pass.
6. Engine/capabilities boundary validation passes.

## Merge Rule

Engine migrations do not merge until all required gates are green and migration evidence is recorded.
