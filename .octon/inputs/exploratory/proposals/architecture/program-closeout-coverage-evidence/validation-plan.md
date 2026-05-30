# Validation Plan

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/program-closeout-coverage-evidence --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/program-closeout-coverage-evidence
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/program-closeout-coverage-evidence --require-implementation-authorization
```

Future implementation must also run program child readiness validation and the
aggregate closeout validator added by this child.
