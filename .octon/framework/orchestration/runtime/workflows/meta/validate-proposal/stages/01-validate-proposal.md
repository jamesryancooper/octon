---
title: Validate Proposal
description: Run the baseline proposal validator, the subtype validator, and the deterministic proposal-registry projection check.
---

# Step 1: Validate Proposal

## Purpose

Prove that the target proposal is structurally valid and that proposal discovery is synchronized with the manifest projection.

## Actions

1. Run `validate-proposal-standard.sh --package <proposal_path>`.
2. Run the subtype validator that matches `proposal.yml#proposal_kind`.
3. Fail closed if any validator fails.
4. Fail closed if `generated/proposals/registry.yml` does not match the deterministic projection rebuilt from proposal manifests.
5. Persist the validator transcript as `standard-validator.log`.
