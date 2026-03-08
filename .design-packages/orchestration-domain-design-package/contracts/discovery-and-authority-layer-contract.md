# Discovery And Authority Layer Contract

## Purpose

This contract defines package-local progressive-disclosure and
single-source-of-truth rules for orchestration surfaces in this specification.

The same layering must be preserved when these surfaces are promoted into live
`.harmony` authority surfaces.

## Core Rule

Every orchestration surface defined by this package must define:

- discovery layer
- routing/metadata layer
- definition layer
- state/evidence layer

Each layer must have one clear source of truth.

## Collection Surface Pattern

Applies to:

- `campaigns`
- `automations`
- `watchers`
- `incidents`

### Layers

| Tier | Artifact | Source Of Truth |
|---|---|---|
| 1 | `manifest.yml` | routing identity, display name, summary, status |
| 2 | `registry.yml` | version, dependencies, I/O, state paths, validation hooks |
| 3 | `<surface-id>/...` | full object definition and local contracts |
| 4 | `state/` plus linked evidence | mutable runtime state and execution traces |

### Rules

1. Tier 1 must stay lightweight and routing-oriented.
2. Tier 2 must hold cross-object metadata, not mutable state.
3. Tier 3 is the source of truth for object definition.
4. Tier 4 is the source of truth for mutable local state.

## Infrastructure Surface Pattern

Applies to:

- `queue`
- `runs`

### `queue`

| Tier | Artifact | Source Of Truth |
|---|---|---|
| 1 | `README.md` | operator discovery and orientation |
| 2 | `registry.yml`, `schema.yml` | queue capabilities, schema, lane definitions |
| 3 | lane directories | active queue items |
| 4 | `receipts/` | append-only completion and terminal handling records |

### `runs`

| Tier | Artifact | Source Of Truth |
|---|---|---|
| 1 | `README.md` | operator discovery and orientation |
| 2 | `index.yml` | run discovery and lightweight projection |
| 3 | `<run-id>.yml`, `by-surface/` | orchestration-facing run records and query projections |
| 4 | `continuity/runs/<run-id>/` | durable evidence bundles |

## Existing Surface Integration

### `workflows`

The package-local workflow integration contract is:

- Tier 1: `manifest.yml`
- Tier 2: `registry.yml`
- Tier 3: `WORKFLOW.md` plus step files
- Tier 4: execution-time run and evidence context outside the workflow
  definition tree (`runtime/runs/` and `continuity/runs/`)

### `missions`

The package-local mission integration contract is:

- `registry.yml`: discovery and lifecycle index
- `mission.md`: mission definition and identity
- `tasks.json`, `log.md`, `context/`: mission-local active state

These shapes align with the current Harmony runtime, but this contract is the
package-local source of truth for how they participate in orchestration.

## Single Source Of Truth Rules

1. Identity fields belong in Tier 1 or the object definition layer, but not both
   unless one is explicitly a projection.
2. Mutable state must not be stored in routing artifacts.
3. Evidence bundles must not become the source of live execution state.
4. Projection indexes may duplicate references for queryability, but must never
   outrank object records or evidence stores as authority.

## Schema Requirement

Artifacts named as required runtime surface files must be schema-backed when
`surface-artifact-schemas.md` marks them as such.

## Promotion Note

When these package-defined surfaces are promoted into live `.harmony`, the same
layering remains mandatory. Promotion may move the files, but it may not merge
discovery, mutable state, and durable evidence into one authority layer.
