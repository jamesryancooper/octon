# Validation Plan

## Proposal Packet Validation

- Run `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery`.
- Run `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery`.
- Run `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery`.
- Run `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh --check`.
- Run `git diff --check`.

## Future Implementation Validation

- Validate `proposal-program-delivery-profile-v1.schema.json`.
- Validate `proposal-program-delivery-receipt-v1.schema.json`.
- Validate workflow shape and workflow registry entries.
- Validate command and skill manifest entries.
- Validate proposal lifecycle hook changes.
- Validate generated proposal registry freshness.
- Validate generated publication freshness for any generated outputs touched by
  implementation.
- Validate governed mechanism integration evidence when a delivered child
  changes a governed mechanism.
- Validate Change closeout alignment.
- Validate repo hygiene cleanup receipt behavior.
- Validate branch landing and branch cleanup authorization gates.
- Validate lifecycle terminal current-state proof.
- Validate product feature catalog entries.
- Run implementation conformance and post-implementation drift/churn gates.

## Negative Controls

- Parent summary substituted for child receipts fails.
- Child receipt omitted from delivery receipt fails.
- Stale generated registry evidence fails.
- Branch-no-pr landing without landing authorization fails.
- Branch cleanup without cleanup authorization fails.
- Repo hygiene deletion without cleanup authorization fails.
- Generated prompt authority overclaim fails.
- Proposal-local file authority overclaim fails.
- Cleaned claim with dirty worktree fails.
- Cleaned claim without synced local main and origin/main fails.
