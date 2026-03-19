# Audit Design Package Output Surface Cutover Receipt

## Profile Selection Receipt

- `change_profile`: `atomic`
- `release_state`: `pre-1.0`
- `rationale`:
  - `audit-design-package` workflow-stage bundles were being written under `/.octon/state/evidence/validation/audits/`, which is reserved for bounded-audit evidence bundles.
  - No external API or cross-repo coordination is involved.
  - No data migration or backfill is required because the failing `...pipeline-smoke*` directories are non-authoritative local shells.
- `profile_facts`:
  - `downtime_tolerance`: not applicable
  - `external_consumer_coordination`: none required
  - `data_migration_backfill`: none
  - `rollback_mechanism`: git revert
  - `blast_radius`: workflow contract, runner, tests, and output-surface docs
  - `compliance_constraints`: keep bounded-audit evidence isolated to `reports/audits/`

## Implementation Plan

1. Move `audit-design-package` workflow bundle output from `reports/audits/` to `reports/workflows/`.
2. Update workflow contract and human-readable workflow docs to match the new sink.
3. Document the `reports/workflows/` surface and require its README in harness structure validation.
4. Extend tests so the runner asserts the new output root and the harness/ audit validators continue to pass.

## Impact Map (code, tests, docs, contracts)

- `code`:
  - `/.octon/framework/engine/runtime/crates/kernel/src/workflow.rs`
  - `/.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `tests`:
  - `/.octon/framework/assurance/runtime/_ops/tests/test-design-package-workflow-runner.sh`
  - `/.octon/framework/assurance/runtime/_ops/tests/test-validate-audit-convergence-contract.sh`
  - `/.github/workflows/harness-self-containment.yml`
- `docs`:
  - `/.octon/framework/cognition/_meta/architecture/README.md`
  - `/.octon/state/evidence/runs/workflows/README.md`
  - `/.octon/framework/orchestration/runtime/workflows/audit/audit-design-package/README.md`
  - `/.octon/framework/orchestration/runtime/workflows/audit/audit-design-package/stages/01-configure.md`
  - `/.octon/framework/orchestration/runtime/workflows/audit/audit-design-package/stages/08-report.md`
- `contracts`:
  - `/.octon/framework/orchestration/runtime/workflows/audit/audit-design-package/workflow.yml`

## Compliance Receipt

- `reports/audits/` remains reserved for bounded-audit evidence bundles.
- `audit-design-package` now uses the workflow execution output surface instead of the bounded-audit surface.
- Harness validation continues to fail closed for authoritative bounded-audit bundles and now also requires workflow output-surface documentation.

## Exceptions/Escalations

- No exception requested.
- Follow-up remains available if Octon wants a stricter first-class contract validator for `reports/workflows/` bundles beyond README-level documentation.
