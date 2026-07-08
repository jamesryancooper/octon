---
name: "proposal-program-delivery"
description: "Coordinate an accepted proposal program through child packet implementation, publication freshness, packet closeout, archive handoff, Change closeout, hosted landing, final sync, branch cleanup, terminal proof, and final hygiene."
steps:
  - id: "bind-profile"
    file: "stages/01-bind-profile.md"
    description: "bind-profile"
  - id: "delivery-readiness-preflight"
    file: "stages/02-delivery-readiness-preflight.md"
    description: "delivery-readiness-preflight"
  - id: "validate-program-state"
    file: "stages/03-validate-program-state.md"
    description: "validate-program-state"
  - id: "run-or-resume-child-lifecycles"
    file: "stages/04-run-or-resume-child-lifecycles.md"
    description: "run-or-resume-child-lifecycles"
  - id: "validate-child-receipts"
    file: "stages/05-validate-child-receipts.md"
    description: "validate-child-receipts"
  - id: "validate-feature-catalog-drift"
    file: "stages/06-validate-feature-catalog-drift.md"
    description: "validate-feature-catalog-drift"
  - id: "route-closeout-and-archive"
    file: "stages/06-route-closeout-and-archive.md"
    description: "route-closeout-and-archive"
  - id: "route-change-closeout"
    file: "stages/07-route-change-closeout.md"
    description: "route-change-closeout"
  - id: "validate-cleanup-sync-proof"
    file: "stages/08-validate-cleanup-sync-proof.md"
    description: "validate-cleanup-sync-proof"
  - id: "emit-delivery-receipt"
    file: "stages/09-emit-delivery-receipt.md"
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
- `feature_catalog_drift_receipt` -> `/.octon/state/evidence/runs/workflows/{{date}}-proposal-program-delivery-{{slug}}/feature-catalog-drift-receipt.yml`: Evidence-only feature-catalog-drift-receipt-v1 output validated by validate-feature-catalog-drift-closeout.sh.

## Steps

1. [bind-profile](./stages/01-bind-profile.md)
2. [delivery-readiness-preflight](./stages/02-delivery-readiness-preflight.md)
3. [validate-program-state](./stages/03-validate-program-state.md)
4. [run-or-resume-child-lifecycles](./stages/04-run-or-resume-child-lifecycles.md)
5. [validate-child-receipts](./stages/05-validate-child-receipts.md)
6. [validate-feature-catalog-drift](./stages/06-validate-feature-catalog-drift.md)
7. [route-closeout-and-archive](./stages/06-route-closeout-and-archive.md)
8. [route-change-closeout](./stages/07-route-change-closeout.md)
9. [validate-cleanup-sync-proof](./stages/08-validate-cleanup-sync-proof.md)
10. [emit-delivery-receipt](./stages/09-emit-delivery-receipt.md)

## Verification Gate

- [ ] profile validates with validate-proposal-program-delivery-profile.sh before any delivery claim
- [ ] admission diagnostics distinguish required delivery inputs from forbidden substitutes before expensive continuation or mutation
- [ ] profile and workflow evidence record target_outcome, release state, order policy, PR policy, stash policy, runner handoff refs when supplied, include-path classification state, and retained preflight refs
- [ ] execution_order_policy enforces child-before-parent-delivery unless a valid target-bound order override receipt is retained
- [ ] delivery-readiness-preflight passes before expensive child lifecycle continuation or parent delivery
- [ ] child packet receipts remain target-owned and parent summary evidence does not replace them
- [ ] feature catalog drift validates with validate-feature-catalog-drift-closeout.sh before parent closeout, delivery, or cleaned claims
- [ ] unresolved child or parent feature-catalog drift blocks completed delivery and records next owning documentation routes without replacing child receipts
- [ ] closeout-change or closeout-worktree owns Change closeout and any hosted mutation
- [ ] git mutation preflight passes before branch-local commit, push, hosted no-PR landing, sync, cleanup, or branch deletion
- [ ] dirty or stale source posture selects a route-owned clean worktree with include-path classification before reconstruction, broad stage-all, staging, or commit
- [ ] branch landing authorization exists before landed, synced, or cleaned claims
- [ ] branch cleanup authorization exists before source branch cleanup claims
- [ ] repo-hygiene-cleanup owns any local residue deletion
- [ ] terminal current-state proof shows local main, origin/main, and landed ref equality
- [ ] delivery receipt validates with validate-proposal-program-delivery-receipt.sh
- [ ] lifecycle postmortem threshold status is recorded when repeated blocker or recovery thresholds apply
- [ ] compact blocker-remediation receipts validate repeated fingerprint, repeated full workflow directory, file-count, and byte-count budget triggers when those triggers apply
- [ ] compact blocker-remediation evidence is evidence-only and does not satisfy child-owned receipts, parent delivery, archive, cleanup, Change, branch cleanup, generated publication, terminal proof, or proposal status claims
- [ ] no-dispatch attempt ledgers validate repeated unchanged no-dispatch and max-step states with key digest, input digest, blocker fingerprint, bounded attempt metadata, and source evidence refs when those triggers apply
- [ ] no-dispatch attempt ledger evidence is evidence-only and does not satisfy child-owned receipts, parent delivery, archive, cleanup, Change, branch cleanup, generated publication, terminal proof, or proposal status claims
- [ ] delivery evidence index validates with validate-proposal-program-delivery-evidence-index.sh and remains evidence-only
- [ ] stop_condition_taxonomy maps blockers to owning routes or validators and prevents aggregate evidence from authorizing missing target-owned receipts

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `proposal-program-delivery` |
