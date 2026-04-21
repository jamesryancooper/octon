# Registry and Active-Doc Discipline Model

## Principle

Structural truth should stay in machine-readable registries. Active docs should explain the model without carrying hand-maintained path matrices, historical wave chronology, or proposal-lineage closeout detail.

## Current strengths

- `.octon/README.md` is concise and registry-backed.
- `specification.md` names `contract-registry.yml` as machine-readable source of truth for topology, authority families, publication metadata, and doc targets.
- `START.md` points operators to the registry and avoids becoming a second authority plane.

## Current weaknesses

- Some active docs still contain historical or transitional language.
- Skills documentation contains both symlink-era host projection language and generated-routing projection language.
- The registry is strong but hard to navigate without generated maps.

## Target generated maps

Publish the following generated, non-authoritative maps:

- `generated/cognition/projections/materialized/architecture-map.md`
- `generated/cognition/projections/materialized/authorization-coverage-map.md`
- `generated/cognition/projections/materialized/publication-freshness-map.md`
- `generated/cognition/projections/materialized/support-proof-map.md`
- `generated/cognition/projections/materialized/compatibility-retirement-map.md`

Each map must trace every field to authored authority, state/control truth, state/evidence proof, or generated source metadata.

## Active-doc hygiene validator

`validate-active-doc-hygiene.sh` must fail on:

- undocumented proposal-path dependency;
- historical wave chronology in active steady-state docs;
- generated artifact described as authority;
- conflicting host projection semantics;
- hand-maintained path matrices that duplicate registry-owned truth.
