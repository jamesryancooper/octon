# Child Packet Contract

## Boundary

Each child packet is independently owned by the proposal-packet lifecycle.
Parent program evidence may coordinate, sequence, and summarize, but it never
satisfies child receipts, child promotion targets, child validation verdicts,
child terminal outcomes, or child archive metadata.

## Required Child Guarantees

- Child directories remain siblings of the parent program and are not nested.
- Child manifests declare `change_profile: atomic`.
- Child packets preserve proposal input non-authority.
- Child packets preserve generated-output derived-only posture.
- Child implementation-grade completeness reviews must pass before
  implementation prompt generation.
- Child proposal reviews must be fresh, accepted, and explicitly authorize
  implementation prompt generation.
- Child executable implementation prompts must require post-implementation
  conformance and drift/churn receipts.
- Child implementation, promotion, verification, closeout, and archive remain
  route-owned.

## Forbidden Parent Transfers

- No child receipt satisfaction.
- No child manifest status edits by parent review or revision.
- No child promotion target ownership.
- No child validation verdict ownership.
- No child archive metadata ownership.
- No generated state hand edits.
- No parent summary as child proof.
