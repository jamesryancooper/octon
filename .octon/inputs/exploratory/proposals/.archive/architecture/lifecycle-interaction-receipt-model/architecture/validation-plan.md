# Validation Plan

## Proposal Validators

- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-interaction-receipt-model`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-interaction-receipt-model`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-interaction-receipt-model --require-implementation-authorization`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-interaction-receipt-model`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-interaction-receipt-model`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/lifecycle-interaction-receipt-model`

## Implementation Validators

- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh --contract .octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-interaction-receipts.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh`

## Negative Controls

The test suite must include explicit failing cases for:

- missing evidence ref
- stale evidence digest
- scope boundary digest mismatch
- forbidden-transfer omission
- authority-bearing evidence class
- completed return without evidence refs
- interaction request used as closeout, cleanup, landing, archive, or promotion
  authority
- runner discovery that does not dispatch without normal target gates
- executor authorization that still fails when required receipts are missing
