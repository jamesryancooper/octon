# Source of Truth Map

This packet preserves Octon's authority boundaries. It does not make proposal
material authoritative.

## Authored authority

| Class | Current repo source | Role in this proposal |
|---|---|---|
| Constitutional architecture | `.octon/framework/cognition/_meta/architecture/specification.md` | Preserves `.octon/` class-root separation and generated/read-model non-authority. |
| Runtime constitutional contracts | `.octon/framework/constitution/contracts/runtime/**` | Source family for run event ledger, run event, runtime state, and state reconstruction. |
| Runtime execution contracts | `.octon/framework/engine/runtime/spec/**` | Source family for execution authorization, receipts, run lifecycle, evidence store, operator read models, runtime events, and authorization-boundary coverage. |
| Instance governance | `.octon/instance/governance/**` | Source for support-target, mission-autonomy, budget, and network/governance overlays. |
| Capability governance | `.octon/framework/capabilities/**` and `.octon/instance/capabilities/**` | Source for capability packs and deny-by-default action surfaces. |
| Assurance/lab | `.octon/framework/assurance/**` and `.octon/framework/lab/**` | Source for proof planes, validators, replay, and regression promotion. |

## Control truth

| Surface | Canonical role |
|---|---|
| `.octon/state/control/execution/runs/<run-id>/events.ndjson` | Canonical append-only Run Journal after promotion. |
| `.octon/state/control/execution/runs/<run-id>/events.manifest.yml` | Canonical ledger integrity and sequence manifest. |
| `.octon/state/control/execution/runs/<run-id>/runtime-state.yml` | Mutable derived view over the Run Journal; never stronger than the journal. |
| `.octon/state/control/execution/runs/<run-id>/run-manifest.yml` | Run identity, roots, lifecycle refs, support-target tuple, and control/evidence roots. |
| `.octon/state/control/execution/runs/<run-id>/rollback-posture.yml` | Rollback/compensation posture and checkpoint refs. |
| `.octon/state/control/execution/approvals/**` | Approval, revocation, and escalation truth when used. |

## Retained evidence

| Surface | Canonical role |
|---|---|
| `.octon/state/evidence/runs/<run-id>/**` | Retained evidence bundle for Run closeout, replay, disclosure, and audit. |
| `.octon/state/evidence/control/execution/**` | Retained control-plane decision evidence. |
| `.octon/state/evidence/validation/**` | Validator, conformance, and promotion proof. |
| `.octon/state/evidence/lab/**` | Lab scenario, replay, regression, and fault-drill evidence. |

## Generated / read-model outputs

| Surface | Rule |
|---|---|
| `.octon/generated/**` | Derived-only; may render operator summaries, registries, and projections, but must not authorize execution, widen support, or replace control/evidence truth. |
| Host labels/comments/checks | Projection-only; may link to canonical Octon roots but must not become authority. |

## Proposal-local authority

This packet may propose promoted content, but while it remains under
`.octon/inputs/exploratory/proposals/**`, it is not authority and must not be a
runtime dependency.

## Boundary rules preserved

1. The Constitutional Engineering Harness owns authority and governance.
2. The Governed Agent Runtime owns execution mechanics under that authority.
3. The Run Journal is control truth/evidence substrate, not a new control plane.
4. Runtime-state files are derived/mutable views over canonical journal events.
5. Generated operator views are disclosure surfaces, not authority surfaces.
