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
   Architecture packets in accepted or implementation-authorized state also
   require a passing strict `support/pre-integration-architecture-review.yml`
   receipt.
   Implemented packets and implemented archives require passing conformance and
   drift/churn receipts.
8. Fail closed if `generated/proposals/registry.yml` does not match the deterministic projection rebuilt from proposal manifests.
9. For terminal verification, run
   `validate-proposal-lifecycle-terminal-freshness.sh --proposal
   <proposal_path>` after the last packet, support receipt, archive, or
   generated artifact mutation.
10. Persist the validator transcript as `standard-validator.log`.
11. Report all five gate states: proposal review, Pre-Integration Architecture
    Review when applicable, implementation-grade completeness, implementation
    conformance, and post-implementation drift/churn.
