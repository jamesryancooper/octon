# Source-of-Truth Map

This packet preserves Octon's existing authority boundaries. It proposes changes
but does not become the source of truth for those changes.

## Canonical authority used by this proposal

| Domain | Canonical source |
| --- | --- |
| Constitutional purpose and non-negotiables | `.octon/framework/constitution/CHARTER.md` |
| Structural topology and surface classes | `.octon/framework/cognition/_meta/architecture/specification.md` |
| Machine-readable architecture registry | `.octon/framework/cognition/_meta/architecture/contract-registry.yml` |
| Authored support declarations | `.octon/instance/governance/support-targets.yml` |
| Runtime authorization contract | `.octon/framework/engine/runtime/spec/execution-authorization-v1.md` |
| Authorized effect-token contract | `.octon/framework/engine/runtime/spec/authorized-effect-token-v1.md` |
| Boundary coverage contract | `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md` |
| Run lifecycle authority | `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` |
| Evidence completeness | `.octon/framework/engine/runtime/spec/evidence-store-v1.md` |
| Operator read-model rules | `.octon/framework/engine/runtime/spec/operator-read-models-v1.md` |

## Derived/read-model inputs consulted

| Surface | Role in this proposal | Authority status |
| --- | --- | --- |
| `.octon/generated/effective/runtime/route-bundle.yml` | Runtime-effective route posture to reconcile | Generated/effective handle; may narrow only |
| `.octon/generated/effective/capabilities/pack-routes.effective.yml` | Capability-pack route posture to reconcile | Generated/effective handle; may narrow only |
| `.octon/generated/effective/governance/support-target-matrix.yml` | Published support matrix to reconcile | Generated read/effective support projection; may not widen |
| `state/evidence/**` examples | Evidence/proof inventory | Evidence only when produced by canonical validators/runs |
| `state/control/**` examples | Run state/control inventory | Mutable control, not proposal authority |

## Forbidden authority sources

This migration must not treat any of the following as runtime or support
authority:

- proposal packets, including this one
- archived proposal packets
- `.octon/inputs/**`
- generated support matrices or read models
- compatibility projections
- README summaries
- support cards without reconciled proof and canonical backing
- disclosures that disagree with reconciled support truth

## Boundary rule

The promotion path must keep one control plane:

- authored authority remains in `framework/**` and `instance/**`
- mutable run control remains in `state/control/**`
- retained evidence remains in `state/evidence/**`
- continuity remains in `state/continuity/**`
- generated/effective artifacts remain derived and freshness-checked
- generated read models remain operator aids, never permission
