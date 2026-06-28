# Feature Catalog Drift Validator

This child implements the validator used by the closeout gate. It compares
authored implementation evidence against current product feature catalog
coverage.

The validator must detect missing catalog entries, stale entries, stale refs,
under-documented changed features, implementation-status mismatches, incorrect
grouping after rename/split/merge, obsolete docs after retirement/removal, and
probably-not-product-feature exclusions.
