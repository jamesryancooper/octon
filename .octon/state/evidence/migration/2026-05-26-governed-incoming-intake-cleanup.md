# Governed Incoming Intake Cleanup Evidence

## Summary

- change_id: `governed-incoming-intake-cleanup`
- date: `2026-05-26`
- scope: remaining cleanup after Governed Incoming Intake Routing migration

## Changes

- Updated active intake wording to describe the four Governed Incoming Intake
  Routing outcomes instead of direct extension/core-skill classification.
- Migrated the local Rust intake unit to the current raw envelope posture:
  `intake.yml`, optional `README.md`, and all raw source material under
  `payload/`.
- Removed legacy `intake-status.yml` and `.DS_Store` noise from the Rust intake
  unit.
- Updated the governed-routing fixture from invalid Rust envelope handling to a
  clean-envelope `single-work-unit-handoff` candidate with advisory handoff
  boundaries.
- Added a separate synthetic invalid-envelope fixture so malformed intake still
  blocks before route classification without depending on the Rust intake being
  invalid.
- Refreshed capability routing and host projections through canonical
  publication scripts after the command manifest summary changed.

## Rust Intake Posture

- intake_id: `octon-rust-skill-pack-rust-source-authority`
- path: `.octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority`
- status: raw additive intake only
- validator findings: `candidate-core-skill`, `provenance-partial`
- route fixture: `single-work-unit-handoff` candidate for target-owned proposal
  packet admission

No installation, extension normalization, extension activation, extension
publication from raw intake, core skill manifest update, generated extension
state, or host skill projection was produced from the Rust intake unit.

## Publication Refresh

- `bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
  published `capabilities-04ee6830ed53`.
- `bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`
  completed through canonical projection paths.

## Validation

- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh --intake-id octon-rust-skill-pack-rust-source-authority`
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-incoming-intake-routing.sh`
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh`
- PASS: `bash .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh --workflow-id process-incoming-intake`
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`
- PASS: `bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh`
- PASS: `git diff --check`
