# Validation Plan

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-architecture-review-route-visibility --skip-registry-check --skip-promotion-target-checks`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-architecture-review-route-visibility`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-architecture-review-route-visibility`

After implementation, add architecture-review status fixtures and receipt-substitution negative controls.
