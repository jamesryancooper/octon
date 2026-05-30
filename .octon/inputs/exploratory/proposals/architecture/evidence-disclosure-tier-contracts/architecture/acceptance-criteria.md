# Acceptance Criteria

_Status: Accepted child acceptance criteria_

The packet is implementation-ready when:

- The four-tier contract exists and uses stable tier ids.
- Existing retained evidence roots remain valid and are not replaced by a clean-sheet model.
- The promotion rule forbids raw-copy promotion from local evidence to publishable evidence.
- Generated read models are explicitly forbidden from satisfying evidence gates.
- Evidence obligations name tier classification without weakening existing closeout evidence requirements.

The implementation must refuse closeout or archive claims until promoted files
exist where required, validators pass, and post-implementation conformance plus
drift/churn receipts pass.
