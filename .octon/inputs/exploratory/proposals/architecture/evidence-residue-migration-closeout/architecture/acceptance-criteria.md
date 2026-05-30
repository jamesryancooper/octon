# Acceptance Criteria

_Status: Accepted child acceptance criteria_

The packet is implementation-ready when:

- Every migrated or retained evidence path has a classification and rollback posture.
- No raw local evidence remains required for hosted/shared closeout.
- Publishable receipts exist where claim evidence is still needed.
- Parent closeout remains blocked until all predecessor child receipts are terminal and fresh.

The implementation must refuse closeout or archive claims until promoted files
exist where required, validators pass, and post-implementation conformance plus
drift/churn receipts pass.
