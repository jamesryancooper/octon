# Implementation Plan

1. Define the aggregate closeout evidence template in the mechanism index or
   closeout guidance.
2. Add validator coverage for required mechanism coverage.
3. Add validator coverage for child receipt freshness and
   child_authority_preserved.
4. Add checks that parent evidence cannot satisfy child receipts.
5. Add checks that proposal lifecycle, Change closeout, worktree closeout, and
   repo hygiene remain separate authority systems.
6. Add explicit optional child deferral handling.
7. Run program child readiness and aggregate closeout validation.
