# Assumptions And Blockers

## Assumptions

- The parent postmortem recommendations are lineage, not authority.
- Current live repository state outranks the parent source matrix when they
  disagree.
- Open gaps are downstream implementation work and do not authorize mutation in
  this revision route.
- The parent program accepted review remains parent-local and cannot satisfy
  child receipts.
- Generated/effective files are derived handles or read models and remain
  non-authoritative.

## Packet-Local Blockers

No packet-local blocker remains after this revision for the selected review
findings. A fresh `review-packet` route must still decide whether the revised
packet is accepted.

## Downstream Blockers

- Workflow retry id allocation is still open.
- Replay-safe resume proof is incomplete.
- Generated freshness preflight is not yet complete before all relevant
  workflow dispatches.
- Promotion evidence binding has partial live support but still needs
  selected-child workflow input checks.
- Terminal routing regression coverage is incomplete for the original duplicate
  workflow id failure.
