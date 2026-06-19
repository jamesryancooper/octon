# Stage 10: Emit Delivery Receipt

Emit an aggregate receipt conforming to `proposal-packet-delivery-receipt-v1`
and validate it with `validate-proposal-packet-delivery-receipt.sh`.

Required checks:

- All source receipts are cited by path or durable evidence reference.
- Aggregate receipt evidence does not replace target-owned packet receipts.
- Non-authority classifications are recorded.
- Generated-freshness outcome is recorded with owner-generator and
  owner-validator references when generated-input scope is detected.
- The aggregate receipt may summarize generated freshness evidence but must not
  replace target-owned freshness, validation, publication, or closeout receipts.
- Proposal-local and parent evidence are invalid as generated freshness,
  publication, closeout, cleanup, or lifecycle authority.
- The aggregate receipt may summarize route-owned terminal proof, but it must
  not replace target-owned terminal proof, cleanup authorization, cleanup
  disposition, final sync, validation, or closeout receipts.
- Missing landing, final sync, cleanup authorization, cleanup disposition,
  rollback posture, validation proof, or terminal proof blocks terminal success
  and `cleaned` claims.
- Open blockers prevent downstream outcome claims.
- Blocked outcomes name explicit blockers and the next owning lifecycle.
- The receipt records the highest outcome that has current passing owning
  evidence.
