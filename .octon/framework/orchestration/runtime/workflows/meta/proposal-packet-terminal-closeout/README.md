---
name: "proposal-packet-terminal-closeout"
description: "Verify implemented proposal packet terminal readiness and emit an archive-ready or blocked aggregate receipt without moving the packet to archive."
steps:
  - id: "bind-profile"
    file: "stages/01-bind-profile.md"
    description: "bind-profile"
  - id: "verify-durable-implementation-state"
    file: "stages/02-verify-durable-implementation-state.md"
    description: "verify-durable-implementation-state"
  - id: "verify-implementation-conformance"
    file: "stages/03-verify-implementation-conformance.md"
    description: "verify-implementation-conformance"
  - id: "verify-post-implementation-drift"
    file: "stages/04-verify-post-implementation-drift.md"
    description: "verify-post-implementation-drift"
  - id: "validate-feature-catalog-drift"
    file: "stages/05-validate-feature-catalog-drift.md"
    description: "validate-feature-catalog-drift"
  - id: "validate-publication-freshness"
    file: "stages/05-validate-publication-freshness.md"
    description: "validate-publication-freshness"
  - id: "classify-repo-hygiene"
    file: "stages/06-classify-repo-hygiene.md"
    description: "classify-repo-hygiene"
  - id: "classify-worktree-hygiene"
    file: "stages/07-classify-worktree-hygiene.md"
    description: "classify-worktree-hygiene"
  - id: "run-evidence-only-reviews"
    file: "stages/08-run-evidence-only-reviews.md"
    description: "run-evidence-only-reviews"
  - id: "resolve-git-github-route"
    file: "stages/09-resolve-git-github-route.md"
    description: "resolve-git-github-route"
  - id: "emit-terminal-receipt"
    file: "stages/10-emit-terminal-receipt.md"
    description: "emit-terminal-receipt"
---

# Proposal Packet Terminal Closeout

_Generated README from canonical workflow `proposal-packet-terminal-closeout`._

## Usage

```text
/proposal-packet-terminal-closeout
```

## Purpose

Verify implemented proposal packet terminal readiness and emit an archive-ready or blocked aggregate receipt without moving the packet to archive.

## Target

This README summarizes the canonical workflow unit at `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout`.

## Prerequisites

- Required workflow inputs are available.
- Canonical workflow contract exists at `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/workflow.yml`.

## Parameters

- `proposal_path` (folder, required=true): Implemented proposal packet to terminalize.
- `target_outcome` (text, required=false): Requested terminal outcome, normally archive-ready.
- `profile_path` (file, required=false): Optional proposal-packet-terminal-closeout-profile-v1 profile.
- `terminal_run_id` (text, required=false): Optional retained terminal closeout run id.
- `lifecycle_interaction_return_refs` (text, required=false): Optional comma-separated lifecycle-interaction-return-v1 refs for governed closeout-worktree residue disposition.

## Failure Conditions

- Required inputs are missing or invalid.
- The canonical workflow contract or stage assets are missing.
- Verification criteria are not satisfied.

## Outputs

- `terminal_profile` -> `/.octon/state/evidence/runs/workflows/{{date}}-proposal-packet-terminal-closeout-{{slug}}/profile.yml`: Bound proposal-packet-terminal-closeout-profile-v1 profile.
- `terminal_receipt` -> `/.octon/state/evidence/runs/workflows/{{date}}-proposal-packet-terminal-closeout-{{slug}}/terminal-receipt.yml`: proposal-packet-terminal-closeout-receipt-v1 aggregate terminal receipt.
- `packet_terminal_receipt` -> `{{proposal_path}}/support/proposal-terminal-closeout.yml`: Packet-local terminal closeout receipt projection.
- `terminal_summary` -> `/.octon/state/evidence/validation/analysis/{{date}}-proposal-packet-terminal-closeout.md`: Top-level packet terminal closeout summary.
- `feature_catalog_drift_receipt` -> `/.octon/state/evidence/runs/workflows/{{date}}-proposal-packet-terminal-closeout-{{slug}}/feature-catalog-drift-receipt.yml`: Evidence-only feature-catalog-drift-receipt-v1 output validated by validate-feature-catalog-drift-closeout.sh.

## Steps

1. [bind-profile](./stages/01-bind-profile.md)
2. [verify-durable-implementation-state](./stages/02-verify-durable-implementation-state.md)
3. [verify-implementation-conformance](./stages/03-verify-implementation-conformance.md)
4. [verify-post-implementation-drift](./stages/04-verify-post-implementation-drift.md)
5. [validate-feature-catalog-drift](./stages/05-validate-feature-catalog-drift.md)
6. [validate-publication-freshness](./stages/05-validate-publication-freshness.md)
7. [classify-repo-hygiene](./stages/06-classify-repo-hygiene.md)
8. [classify-worktree-hygiene](./stages/07-classify-worktree-hygiene.md)
9. [run-evidence-only-reviews](./stages/08-run-evidence-only-reviews.md)
10. [resolve-git-github-route](./stages/09-resolve-git-github-route.md)
11. [emit-terminal-receipt](./stages/10-emit-terminal-receipt.md)

## Verification Gate

- [ ] profile validates under proposal-packet-terminal-closeout-profile-v1
- [ ] state ledger records all eleven workflow states
- [ ] implementation conformance and post-implementation drift validators pass before archive-ready
- [ ] feature-catalog-drift validates with validate-feature-catalog-drift-closeout.sh before archive-ready
- [ ] unresolved feature-catalog drift blocks archive-ready and records next owning lifecycle
- [ ] pre-terminal publication freshness bundle covers capability, extension, runtime route, host projection, proposal registry, proposal artifact, and runtime-effective handle freshness or is blocked with owner route
- [ ] repo-hygiene and worktree hygiene are classified
- [ ] post-integration architecture review and terminal evaluator outputs are evidence-only
- [ ] Git/GitHub route evidence is delegated or explicitly not applicable
- [ ] terminal receipt validates under proposal-packet-terminal-closeout-receipt-v1
- [ ] archive-ready is claimed only when blocker.class is none
- [ ] archive relocation is not performed

## References

- Canonical contract: `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/workflow.yml`
- Canonical stages: `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/stages/`

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Generated from canonical workflow `proposal-packet-terminal-closeout` |
