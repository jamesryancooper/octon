---
schema_version: profile-selection-receipt-v1
proposal_id: octon-architecture-migration-workspace-projects
logical_packet_id: RP-10
recorded_at: 2026-07-12T18:11:19Z
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

RP-10 introduces one final Workspace Project identity model and retires direct
singleton-Profile selection after a bounded read-only compatibility interval.
An indefinite dual model would create competing project identities and make
active-run binding ambiguous.

## Atomic Boundary

Atomic means one canonical project registry and exact project/Profile binding
at completion. It does not mean active runs are rewritten in place. Existing
runs retain their pinned inputs, and rollback preserves all referenced records.

## Exceptions and Escalations

No transitional profile is selected. Escalate only if current repository
evidence proves a clean cutover cannot preserve active-run snapshots or stable
project identity.
