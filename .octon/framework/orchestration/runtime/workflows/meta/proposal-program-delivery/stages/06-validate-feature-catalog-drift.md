# Stage 06: Validate Product Feature Catalog Drift

Validate parent and child product feature catalog drift before parent closeout,
archive routing, delivery, or cleaned claims.

Required checks:

- Run `validate-product-feature-catalog.sh` against
  `.octon/framework/product/features/catalog.yml`.
- Verify child-owned feature-catalog drift receipts when child packets changed
  product-facing or cross-surface features.
- Emit or verify a parent-local `feature-catalog-drift-receipt-v1` receipt
  that summarizes parent-visible drift without replacing child receipts.
- Run `validate-feature-catalog-drift-closeout.sh --receipt <receipt>`.
- Unresolved child or parent feature-catalog drift blocks parent delivery,
  terminal proof, and cleaned claims until the owning documentation route
  resolves it.
- The parent program is coordination lineage only. Parent drift evidence cannot
  satisfy child receipts, child promotion targets, child validation verdicts,
  child closeout evidence, or child archive metadata.
- Generated outputs, raw inputs, host UI state, chat/model memory, and tool
  availability remain non-authority. Retained drift evidence proves the check
  happened but does not authorize future execution or catalog mutation.

Receipt fields:

- `feature_catalog_drift.receipt_ref`
- `feature_catalog_drift.validator_ref`
- `feature_catalog_drift.fresh`
- `feature_catalog_drift.verdict`
- `feature_catalog_drift.outcome`
- `feature_catalog_drift.unresolved_count`
- `feature_catalog_drift.affected_feature_ids`
- `feature_catalog_drift.required_documentation_actions`
- `feature_catalog_drift.child_receipt_refs`
- `feature_catalog_drift.authority_notes`
