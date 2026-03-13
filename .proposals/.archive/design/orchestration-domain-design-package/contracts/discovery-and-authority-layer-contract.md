# Discovery And Authority Layer Contract

## Purpose

This contract defines package-local progressive-disclosure and
single-source-of-truth rules for orchestration surfaces in this specification.

The same layering must be preserved when these surfaces are promoted into live
`.octon` authority surfaces.

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

## Markdown Role

Surface-level Markdown may exist for orientation, authoring guidance, or
operator context, but its role must be explicit and subordinate.

Rules:

1. A surface-level `README.md` may exist to explain purpose, non-goals, safe
   usage, or navigation.
2. A `README.md` is never the canonical contract for discovery, routing,
   definition, mutable state, or durable evidence.
3. Surface-local narrative artifacts such as `README.md`, `mission.md`,
   `timeline.md`, `closure.md`, and `log.md` may explain or summarize, but they
   must not redefine machine-readable authority already assigned elsewhere.
4. Where Markdown is present on collection surfaces such as `automations`,
   `watchers`, or `campaigns`, it sits outside the five authority tiers and
   remains explanatory only.

## Collection Surface Pattern

Applies to:

- `automations`
- `watchers`

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

## Coordination Object Collection Pattern

Applies to:

- `campaigns`

### `campaigns`

| Tier | Artifact | Source Of Truth |
|---|---|---|
| 1 | `manifest.yml` | surface discovery identity |
| 2 | `registry.yml` | campaign lookup projection and lightweight coordination metadata |
| 3 | `<campaign-id>/campaign.yml` | canonical campaign object and mutable coordination-state authority |
| 3 subordinate | `<campaign-id>/log.md` | append-oriented operator notes, waiver rationale, and outcome narrative |
| 4 | none separate in v1 | current campaign state lives in `campaign.yml` rather than a separate `state/` tree |
| 5 | linked mission / decision / run / incident evidence | durable supporting evidence referenced by the campaign without displacing the home-surface authorities |

Campaign-specific authority rules:

1. `campaign.yml` is the single source of truth for campaign identity,
   lifecycle status, mission membership, milestone definitions, and
   completion-waiver metadata.
2. `registry.yml` may project title, status, owner, mission count, milestone
   summaries, and path refs, but it must not outrank `campaign.yml`.
3. `log.md` is evidence and operator guidance. It does not replace required
   structured state or membership fields.
4. Mission lifecycle, run lineage, incident state, and decision evidence remain
   authoritative in their home surfaces. `campaigns` may aggregate them, but
   they do not replace them.
5. `campaigns` intentionally do not use a separate `state/` layer in v1 because
   they coordinate authored mission sets rather than own executor-driven runtime
   state.

## Response Object Surface Pattern

Applies to:

- `incidents`

### `incidents`

| Tier | Artifact | Source Of Truth |
|---|---|---|
| 1 | `README.md` | operator discovery and surface purpose |
| 2 | `index.yml` | global incident lookup projection and lightweight status metadata |
| 3 | `<incident-id>/incident.yml` | canonical incident object and mutable state authority |
| 3 subordinate | `<incident-id>/actions.yml` | optional schema-backed coordination/action set for machine-readable containment, rollback, remediation, or review actions |
| 4 | none separate in v1 | incidents are runtime-born objects, so canonical state lives in `incident.yml` rather than an authored definition layer plus a second mutable-state layer |
| 5 | `<incident-id>/timeline.md`, `<incident-id>/closure.md`, linked run/decision evidence | durable operator-visible evidence and narrative context |

Incident-specific authority rules:

1. `incident.yml` is the single source of truth for severity, status, owner,
   linkage fields, and closure metadata.
2. `index.yml` may project status, severity, owner, closure readiness, and
   path refs, but it must not outrank `incident.yml`.
3. `actions.yml` may coordinate launchable response actions, but it must not
   redefine incident lifecycle or closure authority.
4. `timeline.md` and `closure.md` are evidence and operator guidance. They do
   not become canonical state or authorization.
5. If `status=closed`, closure evidence must exist and `incident.yml` must
   carry the matching closure fields.
6. `incidents` intentionally do not use the `manifest.yml -> registry.yml`
   collection pattern in v1 because they are runtime-created response records,
   not author-authored object definitions.

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
| 2 | `index.yml` | global run-discovery and lightweight lookup projection |
| 3 | `<run-id>.yml` | canonical orchestration-facing run object and current status authority |
| 4 | `by-surface/` | non-authoritative reverse-lookup projections |
| 5 | `continuity/runs/<run-id>/` | durable evidence bundles |

Run-specific authority rules:

1. `runs` has no separate author-authored definition layer in v1; the
   schema-backed `<run-id>.yml` record is the canonical object/state layer.
2. `index.yml` may duplicate lightweight lookup fields, but it must not become
   the source of truth for liveness, coordination, or evidence payload data.
3. `by-surface/` entries are rebuildable query projections derived from
   canonical run records; they must not outrank `<run-id>.yml`.
4. Durable evidence remains external in `continuity/runs/`; runtime
   projections may point to it but must not replace it.

## Existing Surface Integration

### `automations`

The package-local automation integration contract is:

- Tier 1: `manifest.yml`
  - discovery identity, summary, and canonical path reference
- Tier 2: `registry.yml`
  - routing metadata, dependency projections, state pointers, and operator
    summaries derived from the automation definition artifacts
- Tier 3: `<automation-id>/automation.yml`
  - authoritative machine-readable automation identity, workflow target, owner,
    and lifecycle control state
- Tier 3 subordinate required artifacts: `trigger.yml`, `bindings.yml`,
  `policy.yml`
  - authoritative machine-readable trigger selection, input binding/defaulting,
    and admission policy
- Tier 4: `state/status.json`, `state/last-run.json`, `state/counters.json`
  - mutable automation-local operational projections
- Tier 4 linked evidence outside the automation tree
  - continuity decision evidence and run/evidence linkage

Automation-specific authority rules:

1. `automation.yml` is the single source of truth for `automation_id`,
   `workflow_ref`, `owner`, and lifecycle control state.
2. `trigger.yml` is the single source of truth for event/schedule selection and
   dedupe-window configuration.
3. `bindings.yml` is the single source of truth for workflow parameter defaults
   and event input extraction; it must not encode trigger selection or retry
   policy.
4. `policy.yml` is the single source of truth for concurrency, idempotency,
   retry, and automation-local incident policy.
5. `registry.yml` may duplicate selected fields for discovery, but it must not
   outrank the per-automation definition files.
6. `state/*.json` files are projections only; they must not redefine workflow
   target, trigger selection, or policy semantics.

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

- Tier 1: `registry.yml`
  - discovery index and lightweight lifecycle/routing projection
- Tier 2: `<mission-id>/mission.yml`
  - authoritative machine-readable mission object for identity, lifecycle,
    ownership, success criteria, and cross-surface linkage
- Tier 2 subordinate asset: `<mission-id>/mission.md`
  - human-readable goal, scope, constraints, and notes; subordinate to
    `mission.yml`
- Tier 3: `tasks.json`, `context/`
  - mutable mission-local planning state, blockers, and local working context
- Tier 4: `log.md` plus linked `runs/` and continuity evidence
  - append-oriented mission narrative and cross-surface evidence pointers

Mission-specific authority rules:

1. `mission.yml` is the single source of truth for `mission_id`, `status`,
   `owner`, `summary`, `success_criteria`, and mission-local linkage fields.
2. `registry.yml` may duplicate selected fields for discovery, but it must not
   outrank `mission.yml`.
3. `mission.md` may elaborate mission narrative, but it must not redefine
   lifecycle or linkage fields.
4. `tasks.json`, `log.md`, and `context/` are mission-local state/evidence
   helpers; they must not become the canonical lifecycle object.

## Single Source Of Truth Rules

1. Identity fields belong in Tier 1 or the object definition layer, but not both
   unless one is explicitly a projection.
2. Mutable state must not be stored in routing artifacts.
3. Evidence bundles must not become the source of live execution state.
4. Projection indexes may duplicate references for queryability, but must never
   outrank object records or evidence stores as authority.
5. For `workflows`, Markdown instruction assets remain subordinate to the
   schema-backed `workflow.yml` definition artifact.
6. For `missions`, `mission.yml` is the canonical identity/lifecycle/linkage
   artifact; `mission.md` is subordinate narrative; `tasks.json`, `log.md`, and
   `context/` remain mutable mission-local state/evidence only.
7. For `automations`, `automation.yml`, `trigger.yml`, `bindings.yml`, and
   `policy.yml` together form the canonical definition layer; registry and
   state projections must remain subordinate to those artifacts.
8. For `watchers`, emitted event lineage and mutable watcher state must remain
   distinct authority layers even when both are stored near the same runtime
   implementation.
9. For `queue`, local `registry.yml` or `schema.yml` projections must not
   outrank the queue-item contract/schema or imply unsupported named-queue
   identity in v1.
10. For `incidents`, `index.yml` and narrative evidence must remain subordinate
    to the schema-backed `incident.yml` object/state record.
11. For `campaigns`, `campaign.yml` is the canonical object/state record;
    `registry.yml` and `log.md` remain subordinate projection and narrative
    layers.

## Schema Requirement

Artifacts named as required runtime surface files must be schema-backed when
`normative/assurance/surface-artifact-schemas.md` marks them as such.

## Promotion Note

When these package-defined surfaces are promoted into live `.octon`, the same
layering remains mandatory. Promotion may move the files, but it may not merge
discovery, mutable state, and durable evidence into one authority layer.
