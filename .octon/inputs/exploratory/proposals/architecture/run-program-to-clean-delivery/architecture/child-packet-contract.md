# Child Packet Contract

## Boundary

Each child packet is independently owned by the proposal-packet lifecycle. The
parent program may coordinate, sequence, summarize, and validate structure, but
it never satisfies child receipts, child promotion targets, child validation
verdicts, child terminal outcomes, child archive metadata, Change receipts, or
terminal closeout evidence.

## Required Child Guarantees

- Child directories remain siblings of the parent and are not nested.
- Child manifests declare `change_profile: atomic`.
- Child implementation must use the child manifest, promotion targets,
  validators, acceptance criteria, and authority notes.
- Child closeout and archive must be child-owned.
- Parent aggregate receipts may cite child evidence by path and digest only.

## Forbidden Parent Transfers

- No child receipt satisfaction.
- No child manifest status edits by parent routes.
- No child promotion target ownership.
- No child validation verdict ownership.
- No child archive metadata ownership.
- No generated state hand edits.
- No local/private terminal evidence used as hosted/shared closeout proof.
