# Local Development Validation

## Required Local Checks

- `bash .harmony/agency/_ops/scripts/validate/validate-agency.sh`
- `bash .harmony/orchestration/runtime/pipelines/_ops/scripts/validate-pipelines.sh`
- `bash .harmony/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh`
- `bash .harmony/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict`
- `bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `bash .harmony/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,agency,workflows,skills`
- `bash .harmony/assurance/runtime/_ops/tests/test-design-package-workflow-runner.sh`
- `cargo check --manifest-path .harmony/engine/runtime/crates/Cargo.toml`

## Execution-Profile Checks

Validate governance keys and receipt requirements for migration/governance work:

- `change_profile` and `release_state` are present and consistent with semver.
- `transitional_exception_note` is present when `pre-1.0` + `transitional`.
- Required output sections are present:
  - `Profile Selection Receipt`
  - `Implementation Plan`
  - `Impact Map (code, tests, docs, contracts)`
  - `Compliance Receipt`
  - `Exceptions/Escalations`

## Migration Checks

- Verify no legacy `/.harmony/runtime/` references remain.
- Verify engine governance and practice docs are updated with runtime changes.
