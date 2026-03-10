# Discovery And Authority Layer Contract

## Purpose

This contract defines package-local progressive-disclosure and
single-source-of-truth rules for orchestration surfaces in this specification.

The same layering must be preserved when these surfaces are promoted into live
`.harmony` authority surfaces.

## Core Rule

Every orchestration surface defined by this package must define, or explicitly
point to, clear authority for:

- discovery layer
- routing/metadata layer
- definition layer
- mutable state layer
- evidence layer

Each layer must have one clear source of truth.

If a surface does not keep local mutable state or local durable evidence, it
must explicitly name the external authority surface that owns that layer.

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
| 4 | `<surface-id>/state/` | mutable local runtime state |
| 5 | linked evidence / receipts / lineage | durable evidence for emitted or material behavior |

### Rules

1. Tier 1 must stay lightweight and routing-oriented.
2. Tier 2 must hold cross-object metadata, not mutable state.
3. Tier 3 is the source of truth for object definition.
4. Tier 4 is the source of truth for mutable local state.
5. Tier 5 is the source of truth for durable evidence and must not be merged
   back into mutable state.

Where a collection surface does not keep one of these layers locally, the
external owning surface must be named explicitly.

### `watchers`

The package-local watcher integration contract is:

- Tier 1: `manifest.yml`
  - surface discovery identity
- Tier 2: `registry.yml`
  - watcher discovery index, operator metadata, and state-path projections
- Tier 3: `<watcher-id>/watcher.yml`, `sources.yml`, `rules.yml`, `emits.yml`
  - authoritative watcher definition layer
- Tier 4: `<watcher-id>/state/`
  - mutable cursor, health, and suppression state owned by the watcher runner
- Tier 5: emitted event lineage
  - `event_id` keyed evidence linked through queue items, decision records,
    incidents, and any retained watcher-event journal or receipt layer

Watcher-specific authority rules:

1. `watcher.yml`, `sources.yml`, `rules.yml`, and `emits.yml` collectively
   define watcher behavior.
2. `registry.yml` may project selected watcher facts, but it must not outrank
   the watcher definition layer.
3. `state/` is not the evidence layer. Health and cursor snapshots do not
   replace emitted event lineage.
4. Evidence lookup by `event_id` must resolve without using `state/` as the
   canonical source.

## Infrastructure Surface Pattern

Applies to:

- `queue`
- `runs`

### `queue`

| Tier | Artifact | Source Of Truth |
|---|---|---|
| 1 | `README.md` | operator discovery and orientation |
| 2 | `registry.yml`, optional `schema.yml` | routing metadata and references to the queue-item contract/schema |
| 3 | `contracts/queue-item-and-lease-contract.md`, `contracts/schemas/queue-item-and-lease.schema.json` | authoritative queue-item definition, lane semantics, and claim/ack/retry/dead-letter behavior |
| 4 | lane directories | active queue items and mutable intake state |
| 5 | `receipts/` | append-only completion and terminal handling records |

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
  - discovery identity, summary, trigger hints, and canonical path reference
- Tier 2: `registry.yml`
  - routing metadata, commands, access, dependency projections, and optional
    summaries derived from the workflow definition
- Tier 3: `<group>/<workflow-id>/workflow.yml`
  - authoritative machine-readable workflow definition
- Tier 3 subordinate assets: `stages/*.md` and optional `README.md`
  - executor-facing instructions and human guidance resolved only through
    `workflow.yml`
- Tier 4: execution-time run and evidence context outside the workflow
  definition tree (`runtime/runs/` and `continuity/runs/`)

Workflow-specific authority rules:

1. `workflow.yml` is the single source of truth for workflow version, stage
   graph, inputs, artifacts, done gate, and execution controls.
2. `stages/*.md` may elaborate how a stage is executed, but they must not
   redefine execution controls, input contracts, or output declarations.
3. `README.md` is never the canonical execution contract.
4. Registry projections may duplicate selected facts for routing, but they must
   not outrank `workflow.yml`.

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
5. For `workflows`, Markdown instruction assets remain subordinate to the
   schema-backed `workflow.yml` definition artifact.
6. For `watchers`, emitted event lineage and mutable watcher state must remain
   distinct authority layers even when both are stored near the same runtime
   implementation.
7. For `queue`, local `registry.yml` or `schema.yml` projections must not
   outrank the queue-item contract/schema or imply unsupported named-queue
   identity in v1.

## Schema Requirement

Artifacts named as required runtime surface files must be schema-backed when
`surface-artifact-schemas.md` marks them as such.

## Promotion Note

When these package-defined surfaces are promoted into live `.harmony`, the same
layering remains mandatory. Promotion may move the files, but it may not merge
discovery, mutable state, and durable evidence into one authority layer.
