# Acceptance Criteria

_Status: Accepted child acceptance criteria_

The packet is implementation-ready when:

- The local root exists with README guidance but no raw evidence sample is committed.
- The scoped ignore rule prevents accidental tracking of `.octon/state/evidence/local/**`.
- Repo-hygiene policy protects local-only evidence from generic deletion and from publishable closeout claims.
- No repo-root `.gitignore` edit is required by this child packet.

The implementation must refuse closeout or archive claims until promoted files
exist where required, validators pass, and post-implementation conformance plus
drift/churn receipts pass.
