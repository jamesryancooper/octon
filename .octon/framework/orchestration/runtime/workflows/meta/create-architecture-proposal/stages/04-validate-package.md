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
3. Run:
   `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package ".octon/inputs/exploratory/proposals/architecture/<proposal_id>"`
4. Run:
   `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package ".octon/inputs/exploratory/proposals/architecture/<proposal_id>"`
5. Fail closed if structural or subtype validation fails. Treat a draft
   implementation-readiness warning as authoring guidance, not scaffold failure.
   Treat the draft pre-integration architecture review gate as an explicit
   awaiting-review state, not scaffold failure.
6. Persist the validator transcript into the workflow bundle as
   `standard-validator.log`.
7. Record the validator outcome, implementation-grade gate outcome,
   pre-integration review gate outcome, and any follow-up work needed before the
   package is filled in.
8. Confirm the packet identifies supported interfaces and Octon-owned
   integration surfaces whenever external tools are in scope, and rejects
   external-tool modification as an implementation route.

## Proceed When

- [ ] Standard validator passes
- [ ] Implementation-readiness validator ran and recorded a structural-only or implementation-grade gate outcome
- [ ] Proposal review gate ran and recorded an awaiting-review or passing pre-integration architecture review state
- [ ] `standard-validator.log` exists in the workflow bundle
- [ ] Manifest-bearing module requirements are satisfied
- [ ] Registry entry is valid and synchronized
- [ ] README wording and exit path requirements are satisfied
- [ ] External-tool integrity posture is explicit
