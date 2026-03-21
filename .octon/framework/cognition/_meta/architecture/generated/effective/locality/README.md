# Effective Locality Outputs

`generated/effective/locality/**` is the canonical runtime-facing locality
publication family.

## Outputs

- `scopes.effective.yml`
- `artifact-map.yml`
- `generation.lock.yml`

## Rules

- Outputs are compiled from `instance/locality/**` and
  `state/control/locality/quarantine.yml`.
- Outputs are rebuildable and non-authoritative.
- Runtime and policy consumers read locality publication here, not from raw
  locality inputs.
- Scope-local failures may republish a reduced coherent locality set with
  `publication_status: published_with_quarantine`; repo-level locality
  contract failures block publication entirely.
- Stale locality publication fails closed.
