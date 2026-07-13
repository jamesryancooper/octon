---
schema_version: profile-selection-receipt-v1
proposal_id: octon-architecture-migration-recovery-class-b
logical_packet_id: RP-08
recorded_at: 2026-07-12T18:50:24Z
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

One effect cannot be governed by two live retry/outcome interpretations, and a
route predicate cannot change while its zero-prompt behavior is proved. The
final cutover requires one frozen class/route digest, one provider-specific
reconciler, one honest outcome vocabulary, and one run-status source graph.

## Atomic Boundary

Atomic means the live Class B route activates outcome classification,
unknown-before-retry reconciliation, signed evidence, narrow degraded status,
and protected-PR fallback together. It permits scratch-only and shadow/no-effect
rehearsal while production Class B remains disabled.

## Exceptions and Escalations

No transitional profile is selected. Escalate only if dependency proof shows
the clean cutover cannot preserve candidate work or if ROD-002 cannot be
implemented without a separately governed transitional exception.
