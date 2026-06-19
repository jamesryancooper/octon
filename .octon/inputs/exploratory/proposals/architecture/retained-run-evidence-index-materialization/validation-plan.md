# Validation Plan

Run these validators from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/tests/test-generate-retained-run-evidence-index.sh
```

After implementation, also run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
```
