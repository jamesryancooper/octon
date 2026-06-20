# Implementation Plan

## Workstream 1: Change Receipt State Model

- Review branch-no-PR receipt states in
  `.octon/framework/product/contracts/change-receipt-v1.schema.json`.
- Preserve route-specific required fields for branch-local completion, pushed
  branch handoff, hosted landing, final sync, cleanup, and cleaned outcomes.
- Ensure lower actual outcomes remain valid when landing or cleanup evidence is
  unavailable.

## Workstream 2: Closeout-Change Guidance

- Align `closeout-change` with the state model so it can continue from
  published branch to landed, synced, cleaned, and branch-deleted when proof is
  present.
- Keep hosted branch-no-PR landing preflight, landing authorization, final
  sync, and cleanup authorization as explicit gates.
- Keep branch cleanup separate from repo-hygiene cleanup of local run residue.

## Workstream 3: Validation Evidence

- Run change closeout state-machine and lifecycle-alignment validators.
- Run hosted no-PR landing validation.
- Run closeout lifecycle tests covering valid branch-local, published-branch,
  landed, cleaned, and blocked paths plus negative controls for false landed
  and false cleaned outcomes.

## Dependency Preflight

Before durable implementation, verify that
`packet-delivery-wrapper-orchestration-autonomy` has landed or explicitly
record that closeout state-machine implementation is blocked by missing wrapper
orchestration evidence.

## Rollback

Revert Change receipt and closeout-change changes together if routine autonomy
weakens route-specific proof, cleanup authorization, protected-evidence safety,
or lower-outcome reporting.
