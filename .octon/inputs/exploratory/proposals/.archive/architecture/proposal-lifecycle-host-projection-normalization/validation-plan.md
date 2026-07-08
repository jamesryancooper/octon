# Validation Plan

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-host-projection-normalization --skip-registry-check --skip-promotion-target-checks`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-host-projection-normalization`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-host-projection-normalization`

After implementation, add or run:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh`
- host projection parity suite
- extension publication state validation
- route id to command/skill mapping validation
- grep sweeps for canonical names, compatibility aliases, retired names, and
  host-specific omissions
