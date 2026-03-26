# Archive And Decision Map

## Canonical end-state map

### Runtime / governance truth
These remain the authoritative MSRAOM sources:

- `.octon/framework/cognition/governance/principles/mission-scoped-reversible-autonomy.md`
- `.octon/framework/cognition/_meta/architecture/specification.md`
- `.octon/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md`
- `.octon/instance/governance/policies/mission-autonomy.yml`
- `.octon/instance/governance/ownership/registry.yml`
- `.octon/state/control/execution/**`
- `.octon/state/evidence/control/**`
- `.octon/state/evidence/runs/**`
- `.octon/generated/effective/**`
- `.octon/generated/cognition/**`

### Proposal lineage
These become historical lineage only and should all project coherently as
archived history:

- original MSRAOM proposal
- MSRAOM completion-cutover proposal
- MSRAOM steady-state cutover proposal
- MSRAOM final closeout cutover proposal
- this provenance-alignment closeout packet after promotion

### Canonical decision history
Historical ADRs remain intact:

- ADR 063 for the original MSRAOM operating-model cutover
- ADR 064 for the completion cutover
- ADR 066 for the steady-state cutover
- ADR 067 for the final runtime closeout

Add one new durable decision record stating:

- MSRAOM runtime closeout is already complete
- archived proposal packets are historical lineage
- canonical operational roots remain runtime/governance surfaces
- provenance alignment is complete

Add one matching migration plan and evidence bundle stating:

- which archive manifests were normalized
- which registry and index surfaces were rebuilt
- which operator-facing docs were updated
- that no runtime semantic change was part of the cutover

That implementation completion scope is documented in
[`implementation-audit.md`](./implementation-audit.md); this closeout packet is
only the proposal-traceability cleanup.

## Recommended archive posture

### Active proposal workspace
Should contain no MSRAOM packet that reads like unresolved implementation
guidance after this packet itself is archived.

### Archive workspace
Should contain the ordered MSRAOM lineage with:

- normalized archive metadata
- promotion evidence references
- no stray `draft` manifests under archived paths

### ADR / decision root
Should include the final closeout decision, which becomes the canonical answer to:
“Is MSRAOM done?”
