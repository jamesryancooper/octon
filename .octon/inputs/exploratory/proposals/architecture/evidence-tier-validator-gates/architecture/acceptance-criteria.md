# Acceptance Criteria

_Status: Accepted child acceptance criteria_

The packet is implementation-ready when:

- Positive fixtures validate tiered publishable receipts.
- Negative fixtures reject tracked local raw evidence.
- Negative fixtures reject hosted closeout claims that depend on local-only evidence.
- Validator output distinguishes warnings from blocking failures for publishable evidence size.

The implementation must refuse closeout or archive claims until promoted files
exist where required, validators pass, and post-implementation conformance plus
drift/churn receipts pass.
