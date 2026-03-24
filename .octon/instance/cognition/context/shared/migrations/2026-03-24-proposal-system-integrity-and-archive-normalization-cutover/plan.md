---
title: Proposal System Integrity And Archive Normalization Atomic Cutover
description: Atomic clean-break migration plan for proposal contract alignment, deterministic registry generation, lifecycle workflow completion, and archive normalization.
---

# Migration Plan

## Profile Selection Receipt

- Date: 2026-03-24
- Version source(s): `/.octon/octon.yml`
- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- Selection facts:
  - the affected surfaces are repo-local proposal governance, workflow, and
    generated discovery contracts
  - no staged coexistence is desirable because manual registry updates and
    deterministic generation cannot both remain authoritative
  - rollback is a full revert of the cutover plus regeneration of the proposal
    registry
  - archive repair is bounded and repo-local; no external data migration or
    coordination is required

## Implementation Plan

- Align `proposal-standard.md`, subtype standards, template manifests, JSON
  schemas, and validators to one effective proposal contract.
- Introduce `generate-proposal-registry.sh` as the only canonical
  proposal-registry projection path and remove direct registry mutation from
  runner code.
- Add native `validate-proposal`, `promote-proposal`, and `archive-proposal`
  workflow operations plus their workflow contracts and assurance validators.
- Regenerate proposal navigation inventory at scaffold/archive time and lower
  the proposal registry to discovery-only in templates and durable docs.
- Normalize broken archived architecture packets so the fail-closed registry
  projection can pass on the live archive corpus.
- Promote the proposal-system contract into durable repo surfaces, then archive
  the implementing proposal package in the same change set.

## Verification

- `cargo check --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-standard.sh`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-generate-proposal-registry.sh`
- proposal workflow contract validation scripts
- proposal workflow runner tests
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --all-standard-proposals`

## Rollback

- Revert the cutover change set.
- Regenerate `/.octon/generated/proposals/registry.yml` from the reverted
  manifests.
- Restore the proposal-system package to the active workspace only if the
  rollback also reverts the durable proposal-system promotion surfaces.
