# Implementation Plan

1. Implement `document-current-product-feature-gaps`.
   - Add or update catalog entries for the 24 identified features.
   - Add feature notes where boundary explanation is needed.
   - Keep generated/evidence surfaces non-authoritative.
   - Run `validate-product-feature-catalog.sh`.

2. Implement `feature-catalog-drift-closeout-gate`.
   - Add a feature-catalog drift receipt contract if needed.
   - Define evidence inputs and closeout blocking semantics.
   - Place the authoritative gate in delivery and terminal closeout.

3. Implement `feature-catalog-drift-validator`.
   - Compare authored runtime/spec/validator evidence against catalog coverage.
   - Add negative controls for raw/generated/non-authority surfaces.
   - Detect missing, stale, under-documented, status-mismatched, misgrouped,
     obsolete, retired, renamed, split, merged, and downgraded feature docs.

4. Implement `closeout-integration-and-receipts`.
   - Wire the gate into proposal packet delivery, proposal program delivery,
     and proposal packet terminal closeout.
   - Add receipt refs and validation results to retained delivery evidence.
   - Block archive-ready/completed claims when unresolved catalog drift exists.

5. Validate and close out.
   - Run product feature catalog validation.
   - Run delivery and terminal closeout workflow validators.
   - Run the new drift validator and negative-control tests.
   - Preserve child-owned implementation and closeout evidence.
