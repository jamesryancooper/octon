# Implementation Plan

1. Add missing architectural-review validators.
2. Add fixtures and negative controls for all modes and boundaries.
3. Run all proposal and architecture validators.
4. Regenerate proposal registry and compact artifact projections.
5. Run skill and host publication scripts if skill outputs changed.
6. Record rollout evidence and blocker ledger.
7. Validate every child closeout receipt before parent closeout.

## Strict Receipt Requirements

The final completion receipt must list verdicts, evidence refs, validator refs,
unresolved counts, blockers, child packet refs, generated publication refs, and
non-authority classification.
