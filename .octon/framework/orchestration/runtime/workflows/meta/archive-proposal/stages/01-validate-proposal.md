---
title: Validate Proposal Before Archive
description: Confirm that the source proposal is structurally valid before mutating archive state.
---

# Step 1: Validate Proposal Before Archive

## Actions

1. Run `validate-proposal-standard.sh --package <proposal_path>`.
2. Run the subtype validator that matches `proposal.yml#proposal_kind`.
3. Fail closed if any validator fails.
4. Fail closed unless the proposal starts from the active path and is not already archived.
5. Persist the validator transcript as `standard-validator.log`.
