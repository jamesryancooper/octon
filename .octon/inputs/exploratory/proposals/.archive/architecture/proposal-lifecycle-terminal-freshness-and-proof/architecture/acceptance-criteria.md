# Acceptance Criteria

The proposal is acceptable for implementation when:

- native Pre-Integration Architecture Review passes;
- the packet remains `octon-internal` and all promotion targets are under
  `.octon/`;
- terminal proof receipts are evidence-only and cannot authorize mutation;
- generated artifacts remain derived-only;
- parent summaries cannot satisfy child receipts;
- branch-no-pr correction aggregation cannot replace landing or cleanup
  authorization receipts;
- terminal current-state proof cannot replace implementation conformance,
  post-implementation drift/churn, proposal review, or artifact freshness
  validation;
- scoped terminal child validation is allowed only for a declared child set and
  only after program-level registry freshness has passed;
- compact validator logs cannot replace structured validator results or
  receipt schemas;
- canonical validator runtime resolution records corrected invocations without
  weakening validation gates.

Implementation is complete only when:

- both new schemas exist and reject placeholder, prose-only, stale, missing, or
  authority-conflicting receipts;
- all new validators pass with positive and negative controls;
- closeout workflow and closeout skills require terminal proof for applicable
  cleaned claims;
- proposal archive, promote, and validate workflows re-run terminal freshness
  checks after final proposal and generated-state mutations;
- generated proposal registry and artifact-spine validation pass after
  implementation;
- implementation conformance and post-implementation drift/churn receipts pass;
- final closeout records terminal current-state proof and leaves no proposal or
  generated-state residue.
