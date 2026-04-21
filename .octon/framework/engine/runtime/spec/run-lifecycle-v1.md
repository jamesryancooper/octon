# Run Lifecycle v1

This contract defines the fail-closed state machine for consequential run
lifecycle control.

## Canonical Files

Each bound run is anchored by:

- `/.octon/state/control/execution/runs/<run-id>/run-contract.yml`
- `/.octon/state/control/execution/runs/<run-id>/run-manifest.yml`
- `/.octon/state/control/execution/runs/<run-id>/runtime-state.yml`
- `/.octon/state/control/execution/runs/<run-id>/rollback-posture.yml`
- `/.octon/state/evidence/runs/<run-id>/**`
- `/.octon/state/evidence/disclosure/runs/<run-id>/run-card.yml`

`runtime-state.yml` carries the mutable current status. This document is the
normative transition contract that the mutable status must satisfy.

## States

| State | Entry requirements | Required retained facts | Allowed exits |
| --- | --- | --- | --- |
| `draft` | Request exists but no run roots are live. | none beyond request lineage | `bound`, `denied` |
| `bound` | Run contract, manifest, runtime state, rollback posture, and checkpoint roots exist. | bound receipt or equivalent control checkpoint | `authorized`, `denied` |
| `authorized` | Authority decision and grant bundle resolve for the bound run. | decision artifact, grant bundle, support binding | `running`, `staged`, `revoked`, `denied` |
| `running` | Authorized stage attempt is active. | stage-attempt record, runtime receipts, replay growth | `paused`, `failed`, `revoked`, `succeeded`, `staged` |
| `paused` | Execution is intentionally suspended at a safe interrupt boundary. | current checkpoint, operator-visible pause reason | `running`, `revoked`, `failed` |
| `staged` | Route or review posture allows only stage-only continuation. | stage-only authority outcome and current evidence bundle | `authorized`, `revoked`, `closed` |
| `revoked` | Revocation or equivalent stop condition is active. | revocation ref or deny receipt, updated rollback posture | `rolled_back`, `closed` |
| `failed` | Execution failed before successful compensation or closeout. | failure receipt, rollback posture, operator-visible status | `rolled_back`, `closed` |
| `rolled_back` | Rollback or compensation completed. | retained rollback evidence and final checkpoint | `closed` |
| `succeeded` | Requested work finished under a valid support posture. | retained run evidence, assurance, measurement, intervention, RunCard | `closed` |
| `denied` | Request or transition was denied before further consequential work. | denial receipt with reason codes | `closed` |
| `closed` | Evidence completeness, disclosure, and review requirements passed. | closeout-complete retained evidence store | terminal |

## Transition Rules

- `bound` requires canonical run roots before any consequential side effect.
- `authorized` requires both a decision artifact and a grant bundle.
- `running` requires the active stage attempt to remain within the granted
  support-target and capability-pack envelope.
- `paused`, `staged`, `revoked`, and `failed` must remain operator-visible via
  `runtime-state.yml` and refreshed read-model projections.
- `closed` requires evidence-store completeness, current rollback posture,
  canonical disclosure, and any blocking review dispositions to be resolved.
- Any transition missing required authority, evidence, rollback, or visibility
  facts is invalid and must fail closed.

## Notes

- Support-target binding is evaluated against the current admitted tuple model.
- Generated mission views, operator digests, and summaries may mirror lifecycle
  state, but they do not become lifecycle authority.

## Related Contracts

- `/.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `/.octon/framework/engine/runtime/spec/operator-read-models-v1.md`
- `/.octon/framework/constitution/contracts/authority/decision-artifact-v2.schema.json`
- `/.octon/framework/constitution/contracts/authority/grant-bundle-v2.schema.json`
- `/.octon/framework/constitution/contracts/disclosure/run-card-v2.schema.json`
