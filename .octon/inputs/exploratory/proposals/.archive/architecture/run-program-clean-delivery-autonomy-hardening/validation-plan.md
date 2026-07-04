# Validation Plan

## Parent Creation Validation

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening`

## Child Validation

Each child must pass:

- `validate-proposal-standard.sh --package <child> --skip-registry-check`
- `validate-architecture-proposal.sh --package <child>`
- `validate-proposal-implementation-readiness.sh --package <child>`

## Program Readiness Validation

After child review acceptance:

- `validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomy-hardening`

## Durable Implementation Validation

Each child owns route-specific validators, negative controls, conformance
review, drift/churn review, closeout receipt, and archive evidence. Aggregate
program validation must prove the full PM-001 through PM-007 coverage set before
any parent closeout or archive claim.
