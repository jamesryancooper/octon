# Acceptance Criteria

_Status: Accepted child acceptance criteria_

The packet is implementation-ready when:

- Raw cleanup logs are routed to local evidence in implementation guidance.
- Publishable receipts are routed to `.octon/state/evidence/runs/skills/**` for hosted/shared claims.
- Hosted branch-no-pr cleaned closeout has a publishable evidence path and does not require local raw logs.
- Closeout and repo-hygiene remain separate lifecycle routes.

The implementation must refuse closeout or archive claims until promoted files
exist where required, validators pass, and post-implementation conformance plus
drift/churn receipts pass.
