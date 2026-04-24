# Source of Truth Map

## Canonical authority hierarchy used by this packet

| Layer | Role | Current source(s) | Why it matters here |
|---|---|---|---|
| Constitutional kernel | Supreme repo-local control regime | `/.octon/framework/constitution/**` | Prevents lifecycle enforcement from becoming a rival control plane. |
| Umbrella architecture | Class-root topology and authority classes | `/.octon/framework/cognition/_meta/architecture/specification.md` | Defines authored authority, mutable control, retained evidence, generated read models, compatibility projections, and proposal-input boundaries. |
| Terminology | Canonical vocabulary | `/.octon/framework/cognition/_meta/terminology/glossary.md` | Keeps Constitutional Engineering Harness distinct from Governed Agent Runtime, Run, Mission, State, Memory, Working Context, Evidence, Provenance, and Assurance. |
| Runtime contracts | Run execution semantics | `/.octon/framework/engine/runtime/spec/**` | Houses Run Journal v1, Run Lifecycle v1, Authorized Effect Token v1, Context Pack Builder v1, Evidence Store v1, operator read models, execution request/grant/receipt contracts, and authorization coverage. |
| Runtime implementation | Executable enforcement | `/.octon/framework/engine/runtime/crates/**`, `/.octon/framework/engine/runtime/run`, `run.cmd` | Target implementation zone for lifecycle transition validation and state reconstruction. |
| Control state | Mutable operational truth | `/.octon/state/control/execution/runs/<run-id>/**` | Canonical run roots, lifecycle materialization, active context binding, token records, approvals, revocations, checkpoints, and rollback posture. |
| Retained evidence | Factual proof and closeout receipts | `/.octon/state/evidence/runs/<run-id>/**`, `/.octon/state/evidence/disclosure/runs/<run-id>/**` | Required for closeout, RunCard generation, replay, and support proofing. |
| Support targets | Bounded live support universe | `/.octon/instance/governance/support-targets.yml` | Lifecycle enforcement must respect admitted tuples and stage-only surfaces without widening support. |
| Overlay legality | Instance refinement boundaries | `/.octon/framework/overlay-points/registry.yml`, `/.octon/instance/manifest.yml` | Confirms repo-specific runtime assurance or governance overlays must land only at enabled overlay points. |
| Assurance | Proof and validators | `/.octon/framework/assurance/**`, `/.octon/instance/assurance/runtime/**` | Required for lifecycle conformance tests, drift detection, and closeout proof. |
| Generated projections | Derived operator/runtime read models | `/.octon/generated/**` | May mirror lifecycle state but never mint lifecycle authority. |
| Proposal workspace | Non-authoritative planning lineage | `/.octon/inputs/exploratory/proposals/**` | This packet lives here and remains temporary. |

## Non-authoritative surfaces explicitly excluded from lifecycle authority

- Generated operator summaries.
- Generated support matrices except as resolver-verified handles for narrowing only.
- Proposal packet files after promotion.
- Chat transcript text, host UI state, comments, and labels.
- Transport artifacts not reindexed into canonical evidence roots.

## Promotion principle

Promotion must land durable behavior in `framework/**`, `instance/**`, and runtime/assurance code or specs; it must not cause runtime code to depend on this packet.
