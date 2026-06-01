# Implementation Plan

1. Verify current archive observer behavior for active-to-archive moves.
2. Add blocked archive evidence for duplicate run id, stale workflow state,
   missing archive authorization, and non-converged terminal observation.
3. Ensure parent controller consumes blocked archive evidence without claiming
   child terminal completion.
4. Add tests for moved targets, failed workflow, duplicate run id, and blocked
   archive receipts.
