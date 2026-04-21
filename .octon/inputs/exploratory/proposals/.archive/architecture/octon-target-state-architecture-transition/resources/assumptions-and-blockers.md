# Assumptions and Blockers

## Assumptions

- The live repository state inspected on 2026-04-21 is the intended baseline for this packet.
- The proposal standard and architecture proposal standard are the governing packet format.
- The correct target-state path is hardening, not re-foundation.
- Runtime code can be refactored without changing public CLI semantics.
- Generated maps can be introduced as non-authoritative read models with publication receipts.
- Support claims must not widen beyond admitted tuples.

## Blockers

- Any disagreement with constitutional kernel requirements.
- Any proposal target outside `.octon/**` in this packet.
- Any generated artifact promoted as authority.
- Any runtime or policy dependency on the proposal path.
- Any live support expansion without admission and proof.
- Any material side-effect path that cannot be inventoried or mediated.

## Open implementation questions

- Whether authorization phase result artifacts should be retained for every decision or only consequential/material decisions.
- Whether evidence completeness receipts should be schema-owned under constitutional retention contracts or runtime spec contracts.
- Whether generated architecture maps should be rebuilt in CI or by an explicit publication command.
