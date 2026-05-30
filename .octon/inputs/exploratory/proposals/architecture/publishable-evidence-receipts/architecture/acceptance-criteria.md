# Acceptance Criteria

_Status: Accepted child acceptance criteria_

The packet is implementation-ready when:

- The schema validates the representative receipt shape from the best-fit design.
- Receipts are claim-sufficient and do not require raw transcript publication.
- Hosted/shared closeout claims depend on publishable receipts, not local-only evidence.
- Path-only local references are not enough when a raw evidence digest is available.

The implementation must refuse closeout or archive claims until promoted files
exist where required, validators pass, and post-implementation conformance plus
drift/churn receipts pass.
