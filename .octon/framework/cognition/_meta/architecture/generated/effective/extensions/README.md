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
  contributions and may carry `prompt_bundles` metadata for prompt-set
  publication, including `prompt_assets`, bundle-local `reference_assets`, and
  `shared_reference_assets`,
  so runtime consumers do not have to rediscover raw pack content from
  `inputs/**`.
- Runtime trusts the family only when publication status, generation lock,
  receipt linkage, and `state/control/extensions/{active.yml,quarantine.yml}`
  remain coherent.
- Stale extension effective outputs fail closed.
- Publication is valid only when these outputs agree with
  `state/control/extensions/{active.yml,quarantine.yml}`.

## Ownership

The canonical extension ownership model is defined in:

- `/.octon/framework/engine/governance/extensions/README.md`

Local implication for this surface:

- `generated/effective/extensions/**` is the framework-owned publication family
  for extension runtime/read-model outputs.

## Schema Contracts

- `schemas/extension-effective-catalog.schema.json`
- `schemas/extension-artifact-map.schema.json`
- `schemas/extension-generation-lock.schema.json`
