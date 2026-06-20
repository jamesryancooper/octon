# Acceptance Criteria

- Generator-input changes are detected before proposal-packet closeout.
- Generated outputs are refreshed only through owning generators.
- Stale generated outputs block the relevant terminal delivery claim.
- Fresh generated outputs remain non-authoritative.
- Proposal-local and parent evidence do not satisfy generated publication or
  closeout evidence.
- Rollback reverts workflow and generated freshness validator/generator changes
  together.
