# Validation Plan

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-clean-delivery-operator-surface --skip-registry-check --skip-promotion-target-checks`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-clean-delivery-operator-surface`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-clean-delivery-operator-surface`

Child packets must also pass proposal standard, architecture proposal, and implementation readiness validation before implementation prompt generation.

After implementation, add regression coverage for route graph output, command expansion, architecture-review visibility, delivery admission binding, naming/doc alignment, blocked/resume paths, and authority-boundary negative controls.
