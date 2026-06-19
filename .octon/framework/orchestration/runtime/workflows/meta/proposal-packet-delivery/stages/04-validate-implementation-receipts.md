# Stage 04: Validate Implementation Receipts

Validate packet-owned implementation evidence directly before promotion.

Required checks:

- `support/implementation-run.md` reports a passing implementation run.
- Implementation conformance receipts are fresh and passing.
- Post-implementation drift/churn receipts are fresh and passing.
- Generated publication freshness is proven by owning publisher scripts or
  freshness validators.
- Generated-input freshness scope is classified before promotion can feed
  terminal closeout routing.
- Generated refresh, when needed, is routed to the owning generator script and
  validated by the matching owner validator.
- Proposal-local evidence, parent evidence, aggregate delivery receipts, and
  generated read models do not satisfy generated freshness or closeout
  authority.
- Governed mechanism integration receipts are present when applicable.
- Aggregated evidence cites source receipts and does not replace them.
