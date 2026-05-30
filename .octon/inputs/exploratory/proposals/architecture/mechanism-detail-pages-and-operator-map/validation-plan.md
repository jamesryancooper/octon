# Validation Plan

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-detail-pages-and-operator-map --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-detail-pages-and-operator-map
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/mechanism-detail-pages-and-operator-map --require-implementation-authorization
```

Future implementation must also run operator read-model validation and
generated non-authority validation.
