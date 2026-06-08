# Acceptance Criteria

- Tests cover handoff-only default behavior, `--execute-routes` delegation, contract-declared route inventory, phase-context non-authority, promotion ownership, recovery budgets, verification/correction sequencing, hygiene classification, evidence-tier separation, generated-state refresh, timeout handling, implemented-state review-gate behavior, cancellation, resume/replay safety, lock cleanup, no-new-status enforcement, closeout/archive policy, and blocked receipt generation.
- Negative fixtures cover unknown predicates, unsupported blocker classes, unsafe authority boundaries, unsafe resume state, lock integrity ambiguity, missing delegation proof, invalid evidence-tier publication, and attempted local-only evidence requirements for hosted closeout/archive.
- Validation receipts distinguish behavior proof, boundary proof, runtime authorization proof, generated-output freshness proof, and disclosure proof.

## Negative Criteria

- Do not substitute implementation description for behavior tests.
- Do not claim coverage from generated snapshots without canonical source references.
- Do not close the program while required validator, review gate, child-readiness, or source-coverage checks fail.

## Terminal Criteria

- Child implementation evidence exists only after a later
  `run-packet-implementation` route.
- Child promotion is workflow-owned by `promote-proposal` and cannot be claimed
  by parent program evidence.
- Child closeout and archive remain child-owned and route-gated.
