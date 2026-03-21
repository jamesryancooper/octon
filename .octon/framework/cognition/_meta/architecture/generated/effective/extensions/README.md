# Effective Extension Outputs

`generated/effective/extensions/**` is the only runtime-facing extension
surface.

## Outputs

- `catalog.effective.yml`
- `artifact-map.yml`
- `generation.lock.yml`

## Rules

- Effective outputs are rebuildable and non-authoritative.
- Runtime and policy consumers read only these outputs.
- `catalog.effective.yml` carries `routing_exports` for command and skill
  contributions so capability routing does not have to rediscover raw pack
  content from `inputs/**`.
- Runtime trusts the family only when publication status, generation lock,
  receipt linkage, and `state/control/extensions/{active.yml,quarantine.yml}`
  remain coherent.
- Stale extension effective outputs fail closed.
- Publication is valid only when these outputs agree with
  `state/control/extensions/{active.yml,quarantine.yml}`.

## Schema Contracts

- `schemas/extension-effective-catalog.schema.json`
- `schemas/extension-artifact-map.schema.json`
- `schemas/extension-generation-lock.schema.json`
