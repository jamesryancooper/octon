# Validation Plan

During proposal creation:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate --skip-registry-check`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/product-feature-catalog-documentation-and-drift-gate`

During child implementation:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh`
- relevant proposal delivery and terminal closeout workflow validators
- new feature-catalog drift validator and negative-control tests

Baseline catalog validator state:

- The stale proposal-program delivery receipt stage reference that previously
  pointed at `stages/08-emit-delivery-receipt.md` has been repaired to the
  current `stages/09-emit-delivery-receipt.md` path.
- The parent program now treats `validate-product-feature-catalog.sh` as a
  required passing baseline before and after the catalog documentation child
  implementation.
