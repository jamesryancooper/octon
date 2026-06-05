# Implementation Plan

This packet proposes future work only.

1. Define lifecycle recovery classes in the narrowest existing lifecycle
   contract or runtime spec surface.
2. Map each class to allowed recovery actions and escalation conditions.
3. Add examples for enum drift, stale receipts, publication drift, cleanup
   residue, step-budget exhaustion, retryable preflight failure, and noisy
   evidence.
4. Add negative examples for destructive cleanup, missing child receipts,
   parent-summary-only child proof, external approval, and scope expansion.
5. Add tests or validators proving the taxonomy is consumed consistently.
