# Intake Taxonomy Hardening Evidence

## Profile Selection Receipt

- `release_state`: pre-1.0
- `change_profile`: atomic
- `reason`: The migration retires overloaded exploratory surfaces and updates
  validators so raw input authority boundaries fail closed in one change set.

## Decision Framework

An `inputs/**` surface is retained only when it has a distinct lifecycle job, a
stable producer or consumer workflow, an explicit non-authority boundary, and
validator coverage. Surfaces that are empty, generic, duplicated, or named with
overloaded terms are renamed or retired.

## Migration Summary

- Renamed `inputs/exploratory/packages/**` to `inputs/exploratory/reports/**`.
- Replaced top-level `inputs/exploratory/drafts/**` with
  `inputs/exploratory/syntheses/**`.
- Kept `inputs/exploratory/plans/**` for advisory planning artifacts only.
- Moved receipt-like plan files into retained migration evidence.
- Moved active closeout checklist references from a raw proposal archive into
  retained migration evidence.
- Added intake-wide taxonomy documentation and validators for exploratory
  surfaces, input non-authority, and raw archive retention.
- Republished extension state from normalized extension source changes only;
  no raw intake unit was used as publication input.
- Refreshed generated workflow guides, capability routing, host projections,
  and the skills deny-by-default policy catalog through canonical generators.

## Rust Intake Disposition

The Rust source authority intake unit remains raw local additive intake under
`inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority/`. It
was not installed, normalized, activated, published, or projected by this
migration.

## Validation Results

All validations below completed with zero errors:

- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-input-non-authority.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-exploratory-input-surfaces.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-input-archive-retention.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-extension-pack-contract.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-packet8-template-scaffold.sh`
- `bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh --workflow-id process-incoming-intake`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh --intake-id octon-rust-skill-pack-rust-source-authority`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-exploratory-input-surfaces.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-archive-retention.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-authority-surfaces.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`
- `git diff --check`
- `git check-ignore -v .octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority/README.md`
