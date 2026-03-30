# Phase 2 Change Inventory

## Summary

- Added the canonical workspace-charter root under `instance/charter/**` and
  re-bound the objective family, runtime bindings, ingress, and active docs to
  it.
- Kept `instance/bootstrap/OBJECTIVE.md` and
  `instance/cognition/context/shared/intent.contract.yml` as explicit
  compatibility shims rather than the canonical authority pair.
- Populated canonical approval, grant, lease, and revocation artifacts and
  aligned seeded wave4 authority evidence to those artifacts.
- Updated GitHub control-plane workflows so they dual-write canonical approval
  artifacts and no longer use `autonomy:*` labels as merge authority.

## Workspace Charter Re-home

- Added:
  - `/.octon/instance/charter/README.md`
  - `/.octon/instance/charter/workspace.md`
  - `/.octon/instance/charter/workspace.yml`
- Updated the canonical workspace-charter pair contract at
  `framework/constitution/contracts/objective/workspace-charter-pair.yml` to
  point at the new charter pair and record the old bootstrap/cognition paths as
  compatibility shims.
- Updated `octon.yml`, `framework/engine/runtime/config/policy-interface.yml`,
  `framework/cognition/_meta/architecture/contract-registry.yml`, ingress, and
  active bootstrap docs so the canonical objective path now resolves through
  `instance/charter/**`.
- Updated the runtime kernel and run writer so new run contracts bind:
  - `.octon/instance/charter/workspace.md`
  - `.octon/instance/charter/workspace.yml`

## Canonical Authority Artifacts

- Populated canonical approval roots with:
  - `/.octon/state/control/execution/approvals/requests/run-wave4-benchmark-evaluator-20260327.yml`
  - `/.octon/state/control/execution/approvals/grants/grant-run-wave4-benchmark-evaluator-20260327.yml`
- Populated canonical exception and revocation artifacts with:
  - `/.octon/state/control/execution/exceptions/leases.yml#phase2-lease-sample`
  - `/.octon/state/control/execution/revocations/grants.yml#phase2-revocation-sample`
- Populated retained authority control receipts with:
  - `20260329T025914Z-approval-request-materialized.yml`
  - `20260329T025914Z-approval-grant-materialized.yml`
  - `20260329T025922Z-exception-lease-upsert.yml`
  - `20260329T030536Z-authority-revocation-upsert.yml`

## Run Contract And Stage Attempt Path

- Updated runtime-generated run-contract bindings in
  `framework/engine/runtime/crates/kernel/src/authorization.rs` so approval-
  bearing requests record an expected canonical approval grant path in the
  bound run contract.
- Updated the authored run writer
  `framework/orchestration/runtime/_ops/scripts/write-run.sh` and the seeded
  run contracts under `state/control/execution/runs/**` to use the canonical
  workspace charter pair.
- Updated the wave4 sample run contract and retained authority evidence so the
  release-and-boundary-sensitive run now references a real canonical approval
  request/grant, plus the sample lease and revocation artifacts.

## Authority Routing And Host Projection

- Added `framework/engine/_ops/scripts/project-github-control-approval.sh` as
  the reusable GitHub host-projection wrapper over canonical approval request
  and grant materialization.
- Updated `.github/workflows/ai-review-gate.yml` to dual-write AI gate state
  into canonical approval artifacts before syncing projection labels.
- Updated `.github/workflows/pr-auto-merge.yml` to:
  - recompute merge eligibility from PR metadata and changed files
  - materialize canonical approval artifacts for the merge lane
  - stop reading `autonomy:auto-merge` and `autonomy:no-automerge` as merge authority
- Updated `validate-execution-governance.sh` to enforce:
  - GitHub control-plane workflows dual-write into canonical approval artifacts
  - `pr-auto-merge` does not use autonomy labels as merge authority
  - approval, grant, lease, and revocation artifacts are materially populated

## Phase 2 Exit Status

- Every material execution path can produce a run contract: satisfied by the
  runtime kernel bind path and the authored run writer, both of which now use
  the canonical workspace charter pair.
- Approvals/grants/leases/revocations exist as canonical artifacts: satisfied
  by the populated approval roots, lease set, and revocation set in
  `state/control/execution/**`.
- Host-native labels are no longer the authority source: satisfied by the
  `pr-auto-merge` workflow no longer gating on `autonomy:*` labels and the AI
  gate dual-writing canonical approval artifacts before projecting labels.

## Residual Later-Phase Blockers

- Authored disclosure under `instance/governance/disclosure/**` is still
  absent and remains a later-phase item.
- External replay indexing remains structurally present but lightly exercised.
- The runtime still uses `runtime-state.yml` as the practical stand-in for a
  dedicated run manifest.
