# Validation Plan

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/product-doc-boundary-crosslinks --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/product-doc-boundary-crosslinks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/product-doc-boundary-crosslinks --require-implementation-authorization
```

Future implementation must also run product feature catalog validation and link
or terminology checks for the updated product docs.
