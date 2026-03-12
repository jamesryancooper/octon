---
title: Validate Scaffolded Package
description: Run the design-proposal standard validator against the scaffolded package.
---

# Step 4: Validate Scaffolded Package

## Purpose

Ensure the scaffolded package is standard-compliant before reporting success.

## Actions

1. Run:
   `bash .harmony/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package ".proposals/design/<proposal_id>"`
2. Run:
   `bash .harmony/assurance/runtime/_ops/scripts/validate-design-proposal.sh --package ".proposals/design/<proposal_id>"`
3. Fail closed if validation fails.
4. Persist the validator transcript into the workflow bundle as
   `standard-validator.log`.
5. Record the validator outcome and any follow-up work needed before the proposal
   is filled in.

## Proceed When

- [ ] Standard validator passes
- [ ] `standard-validator.log` exists in the workflow bundle
- [ ] Manifest-bearing module requirements are satisfied
- [ ] Registry entry is valid and synchronized
- [ ] README wording and exit path requirements are satisfied
