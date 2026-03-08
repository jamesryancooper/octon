# Discovery And Authority Layer Contract

## Purpose

This contract defines progressive-disclosure and single-source-of-truth rules
for orchestration surfaces promoted into canonical Harmony authority surfaces.

## Core Rule

Every promoted orchestration surface must define:

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

Continue using Harmony's current workflow progressive disclosure model:

- Tier 1: `manifest.yml`
- Tier 2: `registry.yml`
- Tier 3: `WORKFLOW.md`
- Tier 4: step files

### `missions`

Use Harmony's current mission model with an explicit SSOT split:

- `registry.yml`: discovery and lifecycle index
- `mission.md`: mission definition and identity
- `tasks.json`, `log.md`, `context/`: mission-local active state

## Single Source Of Truth Rules

1. Identity fields belong in Tier 1 or the object definition layer, but not both
   unless one is explicitly a projection.
2. Mutable state must not be stored in routing artifacts.
3. Evidence bundles must not become the source of live execution state.
4. Projection indexes may duplicate references for queryability, but must never
   outrank object records or evidence stores as authority.
