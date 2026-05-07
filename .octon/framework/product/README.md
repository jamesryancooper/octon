# Product

`framework/product/` contains product-level contracts and navigation surfaces
that describe how Octon is presented to agents, operators, and maintainers.

## Contents

- `contracts/`: product-level contracts and schemas. These can define durable
  product policy when referenced by the constitutional precedence model.
- `features/`: navigation-only feature catalog. It helps agents find the
  authoritative, runtime, generated, evidence, and validation surfaces for
  cross-surface Octon mechanisms.

Feature catalog entries do not mint authority, support claims, runtime routes,
or generated-effective state. They point to the surfaces that already own those
responsibilities.
