# Docs Services Migration Summary

Generated on 2026-02-12.

## Scope

- Source: `docs/services`
- Target: `.octon/capabilities/runtime/services`
- Strategy: mirror source grouping and create draft stubs for each service doc path.

## Migrated Domains

- `architecture`: 5 service folder(s)
- `authoring`: 4 service folder(s)
- `delivery`: 4 service folder(s)
- `governance`: 5 service folder(s)
- `interfaces`: 1 service folder(s)
- `modeling`: 3 service folder(s)
- `operations`: 5 service folder(s)
- `planning`: 5 service folder(s)
- `quality`: 5 service folder(s)
- `retrieval`: 5 service folder(s)

## Follow-on

- Replace draft placeholders with authoritative service contracts and operational guidance.
- Register production-ready services in `manifest.yml`, `registry.yml`, and `capabilities.yml` as needed.

## Status Update (2026-02-13)

- Full markdown content deleted from `docs/services/**` has been integrated under `.octon/capabilities/runtime/services/**`.
- Canonical references were updated from `docs/services/...` to `.octon/capabilities/runtime/services/...` in active harness docs.
