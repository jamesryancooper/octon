# Runtime Projections

Derived runtime read models and indexes assembled from canonical runtime, continuity, and output artifacts.

## Purpose

- Provide query-friendly projection artifacts without changing source ownership.
- Support faster agent and human traversal for frequently joined views.
- Keep projections explicitly non-authoritative and reproducible.

## Canonical Index

- `index.yml` - machine-readable discovery index for runtime projection artifacts.

## Subsurfaces

- `definitions/` - projection contracts describing source inputs and refresh semantics.
- `materialized/` - generated projection artifacts derived from canonical surfaces.

## Ownership Rule

Projection artifacts are derived views. Source-of-truth remains in canonical runtime, continuity, governance, and output surfaces.
