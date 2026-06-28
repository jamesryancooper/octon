# Validation Plan

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture missing-catalog-entry`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture stale-ref`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh --fixture status-mismatch`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-feature-catalog-drift-closeout.sh`
