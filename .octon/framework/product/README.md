# Product

`framework/product/` contains product-level contracts and navigation surfaces
that describe how Octon is presented to agents, operators, and maintainers.

## Contents

- `contracts/`: product-level contracts and schemas. These can define durable
  product policy when referenced by the constitutional precedence model.
- `features/`: navigation-only feature catalog. It helps agents find the
  authoritative, runtime, generated, evidence, and validation surfaces for
  cross-surface Octon mechanisms.
- `roadmap/`: planning-only follow-up catalog. It helps agents and maintainers
  find deferred cross-surface product work without turning that work into
  runtime state, policy, or support authority.

Feature catalog entries do not mint authority, support claims, runtime routes,
or generated-effective state. They point to the surfaces that already own those
responsibilities.

Architecture and governance boundary detail for cross-surface mechanisms lives
in `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`.
Product docs keep using `product features`; the architecture index uses
`governed cross-surface mechanisms`.

Roadmap entries are planning/navigation records only. They do not create work
queues, support commitments, runtime routes, generated-effective state, or
durable execution evidence.
