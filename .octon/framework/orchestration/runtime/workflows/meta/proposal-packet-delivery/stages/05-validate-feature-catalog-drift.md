# Stage 05: Validate Product Feature Catalog Drift

Validate product feature catalog drift before promotion or downstream closeout
claims.

Required checks:

- Run `validate-product-feature-catalog.sh` against
  `.octon/framework/product/features/catalog.yml`.
- Emit or verify a `feature-catalog-drift-receipt-v1` receipt for the active
  packet under the delivery run evidence bundle.
- Run `validate-feature-catalog-drift-closeout.sh --receipt <receipt>`.
- Classify missing catalog entries, missing feature notes, under-documented
  features, status mismatches, stale refs, obsolete entries, incorrect grouping,
  rename/split/merge cases, downgrade cases, documented changes, documented
  retirements, no-change cases, and probably-not-a-product-feature exclusions.
- Unresolved feature-catalog drift blocks `promote-proposal`, completed
  delivery, `archive-ready`, `landed`, `synced`, `cleaned`, and terminal proof
  claims until the next owning documentation route resolves it.
- The gate does not rewrite product docs, authorize catalog mutation, replace
  target-owned receipts, or widen runtime/support authority.
- Generated outputs, raw inputs, host UI state, chat/model memory, and tool
  availability remain non-authority. Retained drift evidence proves the check
  happened but does not authorize future execution.

Receipt fields:

- `feature_catalog_drift.receipt_ref`
- `feature_catalog_drift.validator_ref`
- `feature_catalog_drift.fresh`
- `feature_catalog_drift.verdict`
- `feature_catalog_drift.outcome`
- `feature_catalog_drift.unresolved_count`
- `feature_catalog_drift.affected_feature_ids`
- `feature_catalog_drift.required_documentation_actions`
- `feature_catalog_drift.authority_notes`
