# Assumptions and Blockers

## Assumptions

1. The stage-2 verification output governs scope.
2. The live repo state observed on 2026-04-14 remains current at implementation start.
3. The active bounded UEC packet is adjacent but not the right container for this refinement.
4. Existing runtime emitters can be updated without introducing a new execution protocol.

## Current blockers

### None that force deferment
Both concepts remain implementable as proposal-first refinements.

### Known implementation unknowns
- Exact runtime code locations that emit instruction-layer manifests were not exhaustively inspected in this packet.
- Exact runtime code locations that write request / grant / receipt payloads were not exhaustively inspected in this packet.
- Anonymous GitHub code search was unavailable during packet preparation, so file discovery relied on targeted path inspection.

These are **implementation discovery tasks**, not proposal blockers.
