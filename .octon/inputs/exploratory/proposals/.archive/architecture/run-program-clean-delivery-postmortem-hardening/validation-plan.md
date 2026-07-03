# Validation Plan

## Parent Creation Validation

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening`

## Child Validation

Each child must pass:

- `validate-proposal-standard.sh --package <child> --skip-registry-check`
- `validate-architecture-proposal.sh --package <child>`
- `validate-proposal-implementation-readiness.sh --package <child>`

## Program Readiness Validation

After child review acceptance:

- `validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-postmortem-hardening`

## Durable Implementation Validation

Each child owns its route-specific validators, negative controls, conformance
review, drift/churn review, closeout receipt, and archive evidence.
