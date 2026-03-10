# Surface: Runs

## Status

- Contract-first
- durable run evidence already exists today in `continuity/runs/`
- a first-class orchestration `runs` surface is proposed for runtime-facing run
  identity, status, and lineage projection

## Core Purpose

`runs` represent concrete execution instances and their outcome, lineage, and
evidence links.

## Responsibilities

- assign and persist run identity
- record status, timestamps, targets, and initiating surface
- link workflows, missions, automations, incidents, and evidence bundles
- provide execution lineage for auditability, replay, and debugging
- expose lightweight projections for reverse lookup by owning surface

## Differentiators

- instance-level, not definition-level
- evidence-oriented, not planning-oriented
- cross-surface connective tissue for autonomous execution

## Complexity

- `Medium`

## Criticality And Ranking

- Criticality: `8/10`
- Usefulness rank: `3`
- Need rank: `3`

## Implementation Contract

See `../contracts/run-linkage-contract.md`,
`../contracts/discovery-and-authority-layer-contract.md`, and
`../contracts/cross-surface-reference-contract.md`.

## Authority Model

- `README.md`
  - operator discovery and orientation only
- `index.yml`
  - global run-discovery and lookup projection
- `<run-id>.yml`
  - canonical orchestration-facing run object and mutable status record
- `by-surface/`
  - non-authoritative reverse-lookup projections derived from canonical run
    records
- `continuity/runs/<run-id>/`
  - durable evidence authority

`runs` does not have a separate author-authored definition layer in v1. The
runtime-generated per-run record is the authoritative object/state layer, while
continuity remains the durable evidence layer.

## Example Use Cases

1. A record of one `audit-continuous-workflow` execution launched by an
   automation, including parameters, status, and evidence bundle location.
2. A governed runtime receipt bundle linked to the exact workflow, mission, and
   incident that caused or responded to a material action.

## Relationships

### Complements Or Supports

- all other execution-oriented surfaces
- especially `workflows`, `missions`, `automations`, and `incidents`

### Depends On

- execution-producing surfaces such as `workflows` and `automations`
- continuity evidence storage

### Surfaces Depend On It

- `incidents`
- operators
- audits
- future analytics or observability surfaces

### Autonomy Posture

- not self-governing
- not autonomous by itself

### Overlap Risks

- overlaps mission state if runs start storing initiative intent
- overlaps continuity logs if runs become narrative history instead of execution
  records
- overlaps checkpoint state if orchestration runs and skill recovery state are
  not clearly separated

## Proposed Canonical Artifacts

```text
orchestration/runtime/runs/
├── README.md
├── index.yml
├── by-surface/
│   ├── workflows/
│   ├── missions/
│   ├── automations/
│   └── incidents/
└── <run-id>.yml
```

Each run record should reference durable evidence under:

```text
continuity/runs/<run-id>/
```

## Non-Goals

- replacing continuity evidence storage
- owning mission progress
- defining new intent or scheduling policy
