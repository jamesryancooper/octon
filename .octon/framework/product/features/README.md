# Product Feature Catalog

This directory is Octon's central navigation catalog for cross-surface product
features.

The catalog answers four questions for agents and operators:

- what the mechanism is called
- what it does
- where the authoritative and runtime surfaces live
- what validation proves the checked-in implementation

## Files

- `catalog.yml`: machine-readable feature index.
- `<feature-id>.md`: human-readable feature notes for individual mechanisms.

## Non-Authority Posture

This catalog is navigation-only. It does not create runtime discovery,
publication authority, support-target admission, policy authority, or durable
execution evidence. Generated outputs remain derived-only, raw inputs remain
non-authoritative, and proposal-local receipts remain evidence only.

## Update Rule

When adding or changing a cross-surface feature entry, update `catalog.yml`,
add or update the matching feature note when helpful, and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
```
