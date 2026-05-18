# Validation Plan

Run the parent validators:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration`

Child packet validators must prove proposal standard conformance, architecture
surface completeness, implementation readiness, accepted review, and
child-specific negative-control coverage before implementation.
