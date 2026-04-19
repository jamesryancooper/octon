# Local Development Validation

## Required Local Checks

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-execution-role-hard-cutover.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-orchestration-design-proposal.sh`
- `bash .octon/framework/orchestration/runtime/_ops/scripts/validate-orchestration-runtime.sh`
- `bash .octon/framework/capabilities/runtime/skills/_ops/scripts/validate-skills.sh --strict`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-alignment-profile-registry.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-authoritative-doc-triggers.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-github-action-pins.sh`
- `OCTON_RUNTIME_STRICT_PACKAGING=1 bash .octon/framework/assurance/runtime/_ops/scripts/validate-runtime-target-parity.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,execution-roles,workflows,skills`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-create-design-proposal-workflow.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-create-design-proposal-workflow.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-create-design-proposal-workflow-runner.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-audit-design-proposal-workflow-runner.sh`
- `cargo check --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml`

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

- Verify no legacy `/.octon/runtime/` references remain.
- Verify engine governance and practice docs are updated with runtime changes.
