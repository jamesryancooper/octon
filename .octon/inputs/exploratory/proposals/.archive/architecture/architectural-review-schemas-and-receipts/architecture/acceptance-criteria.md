# Acceptance Criteria

- Schemas exist under `.octon/framework/constitution/contracts/assurance/`.
- Validators exist for report, routing decision, and support receipt contracts.
- Fixtures cover passing, blocked, not applicable, deferred, and failing cases.
- Negative controls reject placeholder, stale, missing-evidence,
  omitted-validator, ambiguous, and false-pass receipts.
- Existing `review-finding-v1` and `review-disposition-v1` are reused.
- Lifecycle gate wiring is explicitly blocked until these validators pass.
