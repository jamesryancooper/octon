# Workflow Bundle Contract Hardening Receipt

## Profile Selection Receipt

- `change_profile`: `atomic`
- `release_state`: `pre-1.0`
- `rationale`:
  - `reports/workflows/` needed a minimum internal contract so workflow bundles remain self-describing as Octon expands.
  - No external API migration or dual-write period is required.
  - Existing bounded-audit isolation must remain intact.
- `profile_facts`:
  - `downtime_tolerance`: not applicable
  - `external_consumer_coordination`: none required
  - `data_migration_backfill`: none
  - `rollback_mechanism`: git revert
  - `blast_radius`: internal workflow runners, output docs, harness validation, and kernel tests
  - `compliance_constraints`: bounded-audit evidence remains exclusive to `reports/audits/`

## Implementation Plan

1. Define a minimum workflow execution bundle contract for `reports/workflows/`.
2. Update generic workflow runs and `audit-design-package` bundles to emit the contract.
3. Enforce the contract in harness structure validation for authoritative workflow bundles.
4. Add tests that verify the contract files and bundle root for both generic and specialized workflow runners.

## Impact Map (code, tests, docs, contracts)

- `code`:
  - `/.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs`
  - `/.octon/framework/engine/runtime/crates/kernel/src/workflow.rs`
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `tests`:
  - `/.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs`
  - `/.octon/framework/engine/runtime/crates/kernel/src/workflow.rs`
  - `/.octon/framework/assurance/runtime/_ops/tests/test-design-package-workflow-runner.sh`
- `docs`:
  - `/.octon/framework/cognition/_meta/architecture/README.md`
  - `/.octon/state/evidence/runs/workflows/README.md`
- `contracts`:
  - `workflow-execution-bundle` contract for `/.octon/state/evidence/runs/workflows/<YYYY-MM-DD>-<slug>/`

## Compliance Receipt

- Authoritative workflow bundles now require:
  - `bundle.yml`
  - `summary.md`
  - `commands.md`
  - `validation.md`
  - `inventory.md`
  - `reports/`
  - `stage-inputs/`
  - `stage-logs/`
- `bundle.yml` now carries the minimum workflow-bundle metadata pointers and directory identifiers.
- Harness validation enforces the workflow-bundle contract only for authoritative bundles and continues to ignore empty local workspace shells.

## Exceptions/Escalations

- No exception requested.
- The stale local `/.octon/state/evidence/validation/pipelines/` shell was removed after the contract cutover so only the canonical `reports/workflows/` surface remains for new workflow bundles.
