# Validation Plan

Before review or implementation authorization, run:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-governance-efficiency-evaluation --skip-registry-check --skip-promotion-target-checks`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-governance-efficiency-evaluation`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-governance-efficiency-evaluation`

Each child must independently pass proposal standard, architecture proposal, implementation readiness, review, implementation, conformance, drift/churn, validation, closeout, archive, cleanup, and terminal gates when those stages apply.

Feature validation after child implementation must include negative controls proving advisory reports do not authorize lifecycle transitions or replace child-owned evidence.
