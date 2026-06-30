# Implementation Plan

1. Extend the architecture-review receipt validator fixtures to cover matching, stale, missing, and rejected receipt states.
2. Bind review-gate validation to the current packet digest for parent and child proposal packets.
3. Update lifecycle planner review-sensitive transitions to treat stale architecture-review evidence as a specific blocker with a single owning recovery route.
4. Add negative tests proving parent summaries cannot satisfy child-owned review acceptance.
5. Retain validation evidence showing fresh receipts pass and stale receipts fail closed.
