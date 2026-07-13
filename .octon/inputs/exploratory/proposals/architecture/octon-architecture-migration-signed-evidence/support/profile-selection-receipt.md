---
schema_version: profile-selection-receipt-v1
proposal_id: octon-architecture-migration-signed-evidence
logical_packet_id: RP-07
recorded_at: 2026-07-12T18:36:46Z
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

RP-07 must end with one accepted signature envelope, one checkpoint/head chain,
one retention policy, and one evidence truth path. A transition where unsigned
and signed success claims, rollbackable and monotonic heads, or two canonical
journal models coexist would make evidence interpretation ambiguous.

## Atomic Boundary

Atomic means the final live success/publication boundary consumes verified
signatures, current monotonic head, terminal reserve, and bounded retention
together. It does not prohibit inert schemas, shadow signing, or no-delete
compaction rehearsals while autonomous publication remains disabled.

## Exceptions and Escalations

No transitional profile is selected. Escalate only if platform proof shows the
engineering-selected signer, anchor, reserve, or recovery mechanism cannot
preserve the fixed boundary within narrowed ROD-001 risk tolerances without a
separately governed transitional exception.
