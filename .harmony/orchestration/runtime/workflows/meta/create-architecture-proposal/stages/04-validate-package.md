---
title: Validate Scaffolded Package
description: Run the design-package standard validator against the scaffolded package.
---

# Step 4: Validate Scaffolded Package

## Purpose

Ensure the scaffolded package is standard-compliant before reporting success.

## Actions

1. Run:
   `bash .harmony/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package ".proposals/architecture/<proposal_id>"`
2. Fail closed if validation fails.
3. Persist the validator transcript into the workflow bundle as
   `standard-validator.log`.
4. Record the validator outcome and any follow-up work needed before the package
   is filled in.

## Proceed When

- [ ] Standard validator passes
- [ ] `standard-validator.log` exists in the workflow bundle
- [ ] Manifest-bearing module requirements are satisfied
- [ ] Registry entry is valid and synchronized
- [ ] README wording and exit path requirements are satisfied
