---
title: Validate Proposal Before Archive
description: Confirm that the source proposal is structurally valid before mutating archive state.
---

# Step 1: Validate Proposal Before Archive

## Actions

1. Run `validate-proposal-standard.sh --package <proposal_path>`.
2. Run the subtype validator that matches `proposal.yml#proposal_kind`.
3. Run `validate-proposal-implementation-readiness.sh --package <proposal_path>`.
4. Run `validate-proposal-review-gate.sh --package <proposal_path>` so
   architecture proposals preserve their Pre-Integration Architecture Review
   receipt state before archive.
5. When `disposition=implemented`, run
   `validate-proposal-implementation-conformance.sh --package <proposal_path>`
   and `validate-proposal-post-implementation-drift.sh --package <proposal_path>`.
6. Fail closed if any required validator fails.
7. Fail closed unless the proposal starts from the active path and is not already archived.
8. Fail closed for implemented archival unless the completeness, conformance,
   and drift/churn receipts pass or explicit blockers route the packet away
   from implemented archival.
9. Fail closed for superseded archival unless `promotion_evidence` names
   repo-relative successor evidence paths.
10. Persist the validator transcript as `standard-validator.log`.
