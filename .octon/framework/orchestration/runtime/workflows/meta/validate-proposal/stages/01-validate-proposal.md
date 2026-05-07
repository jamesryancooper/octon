---
title: Validate Proposal
description: Run the baseline proposal validator, subtype validator, lifecycle gate validators, and deterministic proposal-registry projection check.
---

# Step 1: Validate Proposal

## Purpose

Prove that the target proposal is structurally valid, lifecycle gate state is
explicit, and proposal discovery is synchronized with the manifest projection.

## Actions

1. Run `validate-proposal-standard.sh --package <proposal_path>`.
2. Run the subtype validator that matches `proposal.yml#proposal_kind`.
3. Run `validate-proposal-implementation-readiness.sh --package <proposal_path>`.
4. Run `validate-proposal-review-gate.sh --package <proposal_path>`.
5. Run `validate-proposal-implementation-conformance.sh --package <proposal_path>`.
6. Run `validate-proposal-post-implementation-drift.sh --package <proposal_path>`.
7. Fail closed if any required validator fails. Draft packets may pass with a
   structural-only readiness warning; accepted, implemented, and executable
   implementation-prompt packets require a passing completeness receipt.
   Implemented packets and implemented archives require passing conformance and
   drift/churn receipts.
8. Fail closed if `generated/proposals/registry.yml` does not match the deterministic projection rebuilt from proposal manifests.
9. Persist the validator transcript as `standard-validator.log`.
10. Report all four gate states: proposal review, implementation-grade
    completeness, implementation conformance, and post-implementation
    drift/churn.
