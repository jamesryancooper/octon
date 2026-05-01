---
title: Validate Scaffolded Package
description: Run the design-proposal standard validator against the scaffolded package.
---

# Step 4: Validate Scaffolded Package

## Purpose

Ensure the scaffolded package is standard-compliant before reporting success.

## Actions

1. Run:
   `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package ".octon/inputs/exploratory/proposals/design/<proposal_id>"`
2. Run:
   `bash .octon/framework/assurance/runtime/_ops/scripts/validate-design-proposal.sh --package ".octon/inputs/exploratory/proposals/design/<proposal_id>"`
3. Run:
   `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package ".octon/inputs/exploratory/proposals/design/<proposal_id>"`
4. Fail closed if structural or subtype validation fails. Treat a draft
   implementation-readiness warning as authoring guidance, not scaffold failure.
5. Persist the validator transcript into the workflow bundle as
   `standard-validator.log`.
6. Record the validator outcome, implementation-grade gate outcome, and any follow-up
   work needed before the proposal is filled in.

## Proceed When

- [ ] Standard validator passes
- [ ] Implementation-readiness validator ran and recorded a structural-only or implementation-grade gate outcome
- [ ] `standard-validator.log` exists in the workflow bundle
- [ ] Manifest-bearing module requirements are satisfied
- [ ] Registry entry is valid and synchronized
- [ ] README wording and exit path requirements are satisfied
