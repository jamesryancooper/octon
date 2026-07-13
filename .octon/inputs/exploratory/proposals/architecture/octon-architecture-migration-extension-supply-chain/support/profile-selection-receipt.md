---
schema_version: profile-selection-receipt-v1
proposal_id: octon-architecture-migration-extension-supply-chain
logical_packet_id: RP-12
recorded_at: 2026-07-12T18:35:31Z
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

RP-12 must finish with one private-release authenticity model, one desired
source/signer/pin policy, one actual availability/active/quarantine model, one
publisher, and one exact generated generation binding. Indefinite digest-only
and signed private admission or floating and exact private selection would make
trust and rollback ambiguous.

## Atomic Boundary

Atomic means the final private path activates strict envelope verification,
exact desired pins, publisher/resolver binding, and RP-11 generation consumption
together. It allows inert schema, verify-to-availability, publisher-disabled,
and Harness-disabled evidence stages because those stages cannot execute a
private extension.

## Exceptions and Escalations

No transitional profile is selected. Escalate only if implementation evidence
shows the bundled-first-party bridge or retained prior generation cannot remain
safe without a time-bounded documented exception.
