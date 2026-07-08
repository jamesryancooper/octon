# Validation Plan

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-clean-delivery-regression-fixtures --skip-registry-check --skip-promotion-target-checks`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-clean-delivery-regression-fixtures`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-clean-delivery-regression-fixtures`

After implementation, run the full fixture matrix and retain compact validator evidence.
