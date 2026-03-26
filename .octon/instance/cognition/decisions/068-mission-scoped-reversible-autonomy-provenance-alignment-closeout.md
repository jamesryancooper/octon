# ADR 068: Mission-Scoped Reversible Autonomy Provenance Alignment Closeout

- Date: 2026-03-25
- Status: Accepted
- Deciders: Octon maintainers
- Related:
  - `/.octon/instance/cognition/context/shared/migrations/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/plan.md`
  - `/.octon/state/evidence/migration/2026-03-25-mission-scoped-reversible-autonomy-provenance-alignment-closeout/`
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-provenance-alignment-closeout/`
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-steady-state-cutover/`
  - `/.octon/inputs/exploratory/proposals/.archive/architecture/mission-scoped-reversible-autonomy-final-closeout-cutover/`
  - `/.octon/instance/cognition/decisions/066-mission-scoped-reversible-autonomy-steady-state-cutover.md`
  - `/.octon/instance/cognition/decisions/067-mission-scoped-reversible-autonomy-final-closeout-cutover.md`

## Context

ADRs 066 and 067 closed the steady-state and final runtime closeout work for
Mission-Scoped Reversible Autonomy. The repo runtime, policy, control, and
generated read-model surfaces already reflect the intended `0.6.3` state.

The remaining issue was not MSRAOM runtime correctness. It was repo-side
provenance drift:

- the archived steady-state and final-closeout proposal manifests still
  declared `status: draft`
- those archived packets did not yet carry explicit archive metadata and
  promotion evidence
- the generated proposal registry omitted the historical steady-state and final
  closeout packets
- proposal history, ADR history, and migration discovery still required manual
  reconciliation to understand that MSRAOM runtime closeout was already done

## Decision

Promote one additional pre-1.0 atomic cutover that closes MSRAOM proposal
provenance without changing runtime semantics.

Rules:

1. ADR 067 remains the canonical runtime-closeout decision for the landed
   `0.6.3` MSRAOM implementation.
2. This ADR becomes the canonical closure statement for proposal-lineage
   normalization and historical discoverability.
3. The archived steady-state and final-closeout proposal manifests must project
   as archived implemented packets with explicit archive metadata and promotion
   evidence.
4. The provenance-alignment packet is itself archived as the final implementing
   packet once the ADR, migration record, evidence bundle, docs, and proposal
   registry converge.
5. Proposal packets remain historical lineage only. Runtime and governance
   truth remain under canonical `instance/**`, `state/**`, and `generated/**`
   roots.
6. No runtime, policy, schema, control-truth, or generated-runtime semantic
   change is part of this cutover.

## Consequences

### Benefits

- MSRAOM history now reads as one coherent lineage across archive, registry,
  ADR, and migration surfaces.
- Future readers no longer need to infer closeout from runtime state alone.
- Historical runtime-closeout ADRs remain append-only and intact.

### Costs

- Additional archival metadata, registry entries, and provenance-closeout
  evidence are committed.
- One more ADR and migration record are added to the cognition discovery
  surfaces.

### Follow-on Work

1. Keep future proposal archival transactions consistent with the same archive
   metadata and promotion-evidence model.
2. If a later MSRAOM redesign happens, supersede this provenance-closeout ADR
   append-only rather than rewriting the archived lineage.
