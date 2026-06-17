---
name: "proposal-packet-delivery"
description: "Coordinate an accepted proposal packet through implementation, promotion, packet closeout, terminal closeout, archive handoff, Change closeout, hosted landing, final sync, branch cleanup, terminal proof, and final hygiene."
steps:
  - id: "bind-profile"
    file: "stages/01-bind-profile.md"
    description: "bind-profile"
  - id: "validate-packet-state"
    file: "stages/02-validate-packet-state.md"
    description: "validate-packet-state"
  - id: "run-or-resume-packet-implementation"
    file: "stages/03-run-or-resume-packet-implementation.md"
    description: "run-or-resume-packet-implementation"
  - id: "validate-implementation-receipts"
    file: "stages/04-validate-implementation-receipts.md"
    description: "validate-implementation-receipts"
  - id: "promote-proposal"
    file: "stages/05-promote-proposal.md"
    description: "promote-proposal"
  - id: "route-packet-closeout"
    file: "stages/06-route-packet-closeout.md"
    description: "route-packet-closeout"
  - id: "route-terminal-closeout-and-archive"
    file: "stages/07-route-terminal-closeout-and-archive.md"
    description: "route-terminal-closeout-and-archive"
  - id: "route-change-closeout"
    file: "stages/08-route-change-closeout.md"
    description: "route-change-closeout"
  - id: "validate-cleanup-sync-proof"
    file: "stages/09-validate-cleanup-sync-proof.md"
    description: "validate-cleanup-sync-proof"
  - id: "emit-delivery-receipt"
    file: "stages/10-emit-delivery-receipt.md"
    description: "emit-delivery-receipt"
---

# Proposal Packet Delivery

_Generated README from canonical workflow `proposal-packet-delivery`._

## Usage

```text
/octon-proposal-run-packet-delivery
```

## Purpose

Coordinate an accepted proposal packet through implementation, promotion, packet closeout, terminal closeout, archive handoff, Change closeout, hosted landing, final sync, branch cleanup, terminal proof, and final hygiene.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/workflow.yml`.

## Parameters

- `profile_path` (file, required=true): Profile conforming to proposal-packet-delivery-profile-v1.
- `target_packet_path` (folder, required=true): Accepted proposal packet path supplied by the caller.
- `target_outcome` (text, required=true): Requested outcome; downstream claims require fresh owning evidence.
- `delivery_run_id` (text, required=true): Stable evidence and receipt run identifier.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `delivery_summary` -> `/.octon/state/evidence/validation/analysis/{{date}}-proposal-packet-delivery.md`: Top-level proposal packet delivery summary.
- `delivery_bundle` -> `/.octon/state/evidence/runs/workflows/{{date}}-proposal-packet-delivery-{{slug}}/`: Workflow bundle containing delivery profile, state evidence, inventory, and receipt.
- `delivery_receipt` -> `/.octon/state/evidence/runs/workflows/{{date}}-proposal-packet-delivery-{{slug}}/proposal-packet-delivery-receipt.yml`: Aggregate proposal-packet-delivery-receipt output validated by validate-proposal-packet-delivery-receipt.sh.

## Steps

1. [bind-profile](./stages/01-bind-profile.md)
2. [validate-packet-state](./stages/02-validate-packet-state.md)
3. [run-or-resume-packet-implementation](./stages/03-run-or-resume-packet-implementation.md)
4. [validate-implementation-receipts](./stages/04-validate-implementation-receipts.md)
5. [promote-proposal](./stages/05-promote-proposal.md)
6. [route-packet-closeout](./stages/06-route-packet-closeout.md)
7. [route-terminal-closeout-and-archive](./stages/07-route-terminal-closeout-and-archive.md)
8. [route-change-closeout](./stages/08-route-change-closeout.md)
9. [validate-cleanup-sync-proof](./stages/09-validate-cleanup-sync-proof.md)
10. [emit-delivery-receipt](./stages/10-emit-delivery-receipt.md)

## Verification Gate

- [ ] profile validates with validate-proposal-packet-delivery-profile.sh before any delivery claim
- [ ] proposal review/readiness gates and implementation authorization are fresh before implementation
- [ ] run-packet-implementation owns implementation execution and target-owned receipts remain authoritative
- [ ] implementation conformance and post-implementation drift/churn pass before promotion
- [ ] promote-proposal owns implemented status and promotion receipt evidence
- [ ] closeout-packet owns proposal-closeout.md and archive authorization
- [ ] proposal-packet-terminal-closeout owns proposal-terminal-closeout.yml
- [ ] archive-proposal owns archive relocation
- [ ] closeout-change or closeout-worktree owns Change closeout and any hosted mutation
- [ ] branch landing authorization exists before landed, synced, or cleaned claims
- [ ] branch cleanup authorization exists before source branch cleanup claims
- [ ] repo-hygiene-cleanup owns any local residue deletion
- [ ] terminal current-state proof shows local main, origin/main, and landed ref equality
- [ ] delivery receipt validates with validate-proposal-packet-delivery-receipt.sh

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `proposal-packet-delivery` |
