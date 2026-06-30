# Validation Plan

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening --skip-registry-check --skip-promotion-target-checks`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening`

Future implementation must add lifecycle surface coherence tests, product catalog and host projection coherence tests, and negative controls for closeout, archive handoff, cleanup, terminal proof, generated-output freshness, and child authority boundaries.
