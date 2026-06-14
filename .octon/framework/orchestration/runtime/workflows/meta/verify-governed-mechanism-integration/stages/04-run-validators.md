# Run Validators

Run the minimum validator set for the selected mode:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package "$proposal_path"
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package "$proposal_path"
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
```

For `closeout` or `archive` mode, also run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal "$proposal_path" --run-registry-check
```

Generated outputs must be refreshed only through canonical publishers or generators before these checks are claimed fresh.
