---
title: Validate Proposal Before Promotion
description: Confirm that the proposal is structurally valid and eligible for promotion before mutating lifecycle state.
---

# Step 1: Validate Proposal Before Promotion

## Actions

1. Run `validate-proposal-standard.sh --package <proposal_path>`.
2. Run the subtype validator that matches `proposal.yml#proposal_kind`.
3. Fail closed if any validator fails.
4. Fail closed unless the proposal lives in the active path and currently uses `status: accepted`.
5. Persist the validator transcript as `standard-validator.log`.
