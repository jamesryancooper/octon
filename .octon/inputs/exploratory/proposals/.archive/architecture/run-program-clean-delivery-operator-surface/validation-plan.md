# Validation Plan

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface --skip-registry-check`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface`
- `validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface --require-implementation-authorization`
- `validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface --mode pre-integration-architecture-review --require-pass`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface`
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface`
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface`
- `validate-proposal-program-delivery-workflow.sh`
- `validate-product-feature-catalog.sh`

The operator surface validation proves the command, skill, feature catalog, and
lifecycle handoff docs are wired to Proposal Program Delivery while remaining
non-authoritative for implementation, archive, cleanup, Git mutation, branch
cleanup, terminal proof, or a final `cleaned` claim.
