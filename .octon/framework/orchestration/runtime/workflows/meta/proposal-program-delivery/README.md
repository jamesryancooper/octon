---
name: "proposal-program-delivery"
description: "Coordinate an accepted proposal program through child packet implementation, publication freshness, packet closeout, archive handoff, Change closeout, hosted landing, final sync, branch cleanup, terminal proof, and final hygiene."
steps:
  - id: "bind-profile"
    file: "stages/01-bind-profile.md"
    description: "bind-profile"
  - id: "validate-program-state"
    file: "stages/02-validate-program-state.md"
    description: "validate-program-state"
  - id: "run-or-resume-child-lifecycles"
    file: "stages/03-run-or-resume-child-lifecycles.md"
    description: "run-or-resume-child-lifecycles"
  - id: "validate-child-receipts"
    file: "stages/04-validate-child-receipts.md"
    description: "validate-child-receipts"
  - id: "route-closeout-and-archive"
    file: "stages/05-route-closeout-and-archive.md"
    description: "route-closeout-and-archive"
  - id: "route-change-closeout"
    file: "stages/06-route-change-closeout.md"
    description: "route-change-closeout"
  - id: "validate-cleanup-sync-proof"
    file: "stages/07-validate-cleanup-sync-proof.md"
    description: "validate-cleanup-sync-proof"
  - id: "emit-delivery-receipt"
    file: "stages/08-emit-delivery-receipt.md"
    description: "emit-delivery-receipt"
---

# Proposal Program Delivery

_Generated README from canonical workflow `proposal-program-delivery`._

## Usage

```text
/proposal-program-delivery
```

## Purpose

Coordinate an accepted proposal program through child packet implementation, publication freshness, packet closeout, archive handoff, Change closeout, hosted landing, final sync, branch cleanup, terminal proof, and final hygiene.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`.

## Parameters

- `profile_path` (file, required=true): Profile conforming to proposal-program-delivery-profile-v1.
- `target_program_path` (folder, required=true): Accepted proposal program path supplied by the caller.
- `target_outcome` (text, required=true): Requested outcome; downstream claims require fresh owning evidence.
- `delivery_run_id` (text, required=true): Stable evidence and receipt run identifier.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `delivery_summary` -> `/.octon/state/evidence/validation/analysis/{{date}}-proposal-program-delivery.md`: Top-level proposal program delivery summary.
- `delivery_bundle` -> `/.octon/state/evidence/runs/workflows/{{date}}-proposal-program-delivery-{{slug}}/`: Workflow bundle containing delivery profile, state evidence, inventory, and receipt.
- `delivery_receipt` -> `/.octon/state/evidence/runs/workflows/{{date}}-proposal-program-delivery-{{slug}}/proposal-program-delivery-receipt.yml`: Aggregate proposal-program-delivery-receipt output validated by validate-proposal-program-delivery-receipt.sh.
- `delivery_evidence_index` -> `/.octon/state/evidence/runs/workflows/{{date}}-proposal-program-delivery-{{slug}}/proposal-program-delivery-evidence-index.yml`: Compact retained delivery evidence index validated by validate-proposal-program-delivery-evidence-index.sh; evidence-only and non-authorizing.

## Steps

1. [bind-profile](./stages/01-bind-profile.md)
2. [validate-program-state](./stages/02-validate-program-state.md)
3. [run-or-resume-child-lifecycles](./stages/03-run-or-resume-child-lifecycles.md)
4. [validate-child-receipts](./stages/04-validate-child-receipts.md)
5. [route-closeout-and-archive](./stages/05-route-closeout-and-archive.md)
6. [route-change-closeout](./stages/06-route-change-closeout.md)
7. [validate-cleanup-sync-proof](./stages/07-validate-cleanup-sync-proof.md)
8. [emit-delivery-receipt](./stages/08-emit-delivery-receipt.md)

## Verification Gate

- [ ] profile validates with validate-proposal-program-delivery-profile.sh before any delivery claim
- [ ] child packet receipts remain target-owned and parent summary evidence does not replace them
- [ ] closeout-change or closeout-worktree owns Change closeout and any hosted mutation
- [ ] branch landing authorization exists before landed, synced, or cleaned claims
- [ ] branch cleanup authorization exists before source branch cleanup claims
- [ ] repo-hygiene-cleanup owns any local residue deletion
- [ ] terminal current-state proof shows local main, origin/main, and landed ref equality
- [ ] delivery receipt validates with validate-proposal-program-delivery-receipt.sh
- [ ] delivery evidence index validates with validate-proposal-program-delivery-evidence-index.sh and remains evidence-only

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `proposal-program-delivery` |
