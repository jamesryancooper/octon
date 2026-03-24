---
title: Validate Scaffolded Package
description: Run the fail-closed proposal validator stack against the scaffolded architecture proposal.
---

# Step 4: Validate Scaffolded Package

## Purpose

Ensure the scaffolded proposal is standard-compliant before reporting success.

## Actions

1. Run:
   `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package ".octon/inputs/exploratory/proposals/architecture/<proposal_id>"`
2. Run:
   `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package ".octon/inputs/exploratory/proposals/architecture/<proposal_id>"`
3. Fail closed if validation fails.
4. Persist the validator transcript into the workflow bundle as
   `standard-validator.log`.
5. Record the validator outcome and any follow-up work needed before the package
   is filled in.

## Proceed When

- [ ] Standard validator passes
- [ ] `standard-validator.log` exists in the workflow bundle
- [ ] Manifest-bearing module requirements are satisfied
- [ ] Registry entry is valid and synchronized
- [ ] README wording and exit path requirements are satisfied
