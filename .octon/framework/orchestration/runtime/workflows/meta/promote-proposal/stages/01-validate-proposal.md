---
title: Validate Proposal Before Promotion
description: Confirm that the proposal is structurally valid and eligible for promotion before mutating lifecycle state.
---

# Step 1: Validate Proposal Before Promotion

## Actions

1. Run `validate-proposal-standard.sh --package <proposal_path>`.
2. Run the subtype validator that matches `proposal.yml#proposal_kind`.
3. Run `validate-proposal-implementation-readiness.sh --package <proposal_path>`.
4. Run `validate-proposal-review-gate.sh --package <proposal_path> --require-implementation-authorization`.
5. Fail closed if any validator fails.
6. Fail closed unless the proposal lives in the active path and currently uses `status: accepted`.
7. Fail closed unless `support/implementation-grade-completeness-review.md`
   records `verdict: pass`, `unresolved_questions_count: 0`, and
   `clarification_required: no`.
8. Fail closed unless `support/proposal-review.md` records a fresh
   `verdict: accepted`, `implementation_prompt_authorized: yes`, zero open
   blocking findings, and a reviewed packet digest matching current
   decision-bearing packet content.
9. Confirm the promotion plan includes post-promotion receipts at
   `support/implementation-conformance-review.md` and
   `support/post-implementation-drift-churn-review.md`; do not claim
   implemented closeout until their validators pass after durable changes land.
10. Persist the validator transcript as `standard-validator.log`.
