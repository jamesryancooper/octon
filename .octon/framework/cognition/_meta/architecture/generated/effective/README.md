# Effective Publication Architecture

`generated/effective/**` is the only runtime-facing generated publication
surface.

## Families

- `locality/`
- `capabilities/`
- `extensions/`

Every effective family publishes:

- a primary effective view
- `artifact-map.yml`
- `generation.lock.yml`

Every effective family must carry:

- `schema_version`
- `generator_version` (the publication generator contract version, not the
  harness release semver)
- `generation_id`
- `published_at`
- source digests
- published file lineage
