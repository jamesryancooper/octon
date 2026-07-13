---
schema_version: profile-selection-receipt-v1
proposal_id: octon-architecture-migration-harness-factory
logical_packet_id: RP-11
recorded_at: 2026-07-12T18:20:41Z
release_state: pre-1.0
change_profile: atomic
atomic_mode: clean-break
transitional_exception_required: false
---

# Profile Selection Receipt

## Selection

Use the repository default `atomic` profile for this pre-1.0 architecture
change.

## Rationale

RP-11 must end with one accepted compiler identity, one complete launch-bound
manifest, and one provider dispatch seam. An indefinite transition with two
accepted manifests or direct and generic provider dispatch would create a
time-of-check gap and ambiguous execution semantics.

## Atomic Boundary

Atomic means the final live behavior cuts over complete compilation,
authorization binding, immediate spawn validation, and generic adapter dispatch
together. It does not prohibit inert contracts, a no-launch shadow compiler,
or adapter-disabled conformance stages used to collect evidence.

## Exceptions and Escalations

No transitional profile is selected. Escalate only if current implementation
evidence proves an atomic behavioral cutover cannot preserve candidate work or
the frozen RP-01/RP-02/RP-10 interfaces.
