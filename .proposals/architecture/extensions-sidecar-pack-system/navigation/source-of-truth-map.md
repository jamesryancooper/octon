# Source Of Truth Map

## Canonical Authority

| Concern | Source of truth | Notes |
| --- | --- | --- |
| Root harness extension binding and compatibility contract | `.octon/octon.yml` | Declares root-only extension scope plus `versioning.harness.release_version` and `extensions.api_version` |
| Pack installation and enablement | `.octon.extensions/catalog.yml` | Selection plane only; no trust or provenance authority |
| Pack-local identity, version, trust, compatibility, dependencies, and content entrypoints | `.octon.extensions/<pack-id>/pack.yml` | Authoritative pack manifest for one installed pack id |
| Pack-contributed skills metadata | `.octon.extensions/<pack-id>/skills/manifest.fragment.yml` and `registry.fragment.yml` | Additive only; cannot redefine core globals |
| Pack-contributed skill instructions | `.octon.extensions/<pack-id>/skills/<skill-id>/SKILL.md` | Authoritative for the pack skill only |
| Pack-contributed commands metadata | `.octon.extensions/<pack-id>/commands/manifest.fragment.yml` | Additive only |
| Pack-contributed command content | `.octon.extensions/<pack-id>/commands/<command-id>.md` | Authoritative for the pack command only |
| Pack-contributed templates metadata | `.octon.extensions/<pack-id>/templates/catalog.fragment.yml` | Additive template catalog fragment |
| Pack-contributed templates content | `.octon.extensions/<pack-id>/templates/**` | Template-local manifests remain authoritative |
| Pack-contributed prompts metadata | `.octon.extensions/<pack-id>/prompts/catalog.fragment.yml` | Additive prompts catalog fragment |
| Pack-contributed prompts content | `.octon.extensions/<pack-id>/prompts/**` | Prompt files are authoritative for pack prompt content |
| Pack-contributed context metadata | `.octon.extensions/<pack-id>/context/catalog.fragment.yml` | Additive context catalog fragment |
| Pack-contributed context docs | `.octon.extensions/<pack-id>/context/**` | Reference-only material |
| Pack-local validation metadata | `.octon.extensions/<pack-id>/validation/catalog.fragment.yml` | Additive validation catalog fragment |
| Pack-local validation assets | `.octon.extensions/<pack-id>/validation/**` | Validates pack content; not global policy |

## Derived Or Enforced Projections

| Concern | Derived path | Notes |
| --- | --- | --- |
| Effective skills catalogs | `.octon/engine/_ops/state/extensions/effective/skills/**` | Derived runtime-facing projection |
| Effective commands catalog | `.octon/engine/_ops/state/extensions/effective/commands/manifest.yml` | Derived runtime-facing projection |
| Effective templates catalog | `.octon/engine/_ops/state/extensions/effective/templates/catalog.yml` | Derived runtime-facing projection |
| Effective prompts catalog | `.octon/engine/_ops/state/extensions/effective/prompts/catalog.yml` | Derived runtime-facing projection |
| Effective context catalog | `.octon/engine/_ops/state/extensions/effective/context/catalog.yml` | Derived runtime-facing projection |
| Effective validation catalog | `.octon/engine/_ops/state/extensions/effective/validation/catalog.yml` | Derived runtime-facing projection |
| Effective artifact map | `.octon/engine/_ops/state/extensions/effective/artifacts.yml` | Canonical rebased mapping from effective ids to source files and digests |
| Effective permission and output rebase metadata | `.octon/engine/_ops/state/extensions/effective/artifacts.yml` | Includes rebased write scopes and Octon-owned output targets for extension artifacts |
| Extension lock / resolution receipt | `.octon/engine/_ops/state/extensions/lock.yml` | Active generation id, input digests, and resolution metadata |
| Extension validation receipts and audit output | `.octon/output/reports/**` and `.octon/engine/_ops/state/extensions/**` | Produced by Octon validators and lifecycle workflows |
| Runtime precedence and fail-closed behavior | `.octon/engine/governance/**` | Remains inside Octon core |
| Governance, practices, methodology, agency, and orchestration authority | `.octon/**` | `.octon.extensions/` must not duplicate these surfaces |

## Boundary Rules

- Raw `.octon.extensions/` paths must not become direct live dependencies of canonical
  `.octon/` manifests or registries.
- `.octon.extensions/` is a pack source surface, not a second runtime authority root.
- Derived effective catalogs may reference pack-owned artifacts after
  validation, but the effective catalogs and artifact map remain the
  runtime-facing projection.
- Catalog vs pack-manifest mismatches fail closed.
- Runtime consumers must resolve extension artifacts through the effective
  artifact map, not by interpreting pack-relative paths directly.
- Runtime writes and durable outputs declared by extension artifacts must be
  served from Octon-owned destinations recorded in the effective artifact map.
- Octon-side commands, workflows, and scaffolds may operate on `.octon.extensions/`
  as an implementation surface while remaining subordinate to `.octon/`
  runtime and governance authority.
- Fallback to core-only mode must withdraw stale extension-derived host and
  policy projections.
