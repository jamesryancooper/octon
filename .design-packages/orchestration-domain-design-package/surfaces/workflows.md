# Surface: Workflows

## Status

- Current Harmony surface

## Core Purpose

`workflows` are bounded, agent-readable, multi-step procedures with explicit
verification gates.

## Responsibilities

- define ordered steps for bounded work
- capture prerequisites, failure conditions, and outputs
- provide reusable procedural contracts
- support checkpointed or parallelized execution where appropriate

## Differentiators

- procedural rather than strategic
- bounded and rerunnable
- reusable across missions, operators, and automations

## Complexity

- `Medium`

## Criticality And Ranking

- Criticality: `10/10`
- Usefulness rank: `1`
- Need rank: `1`

## Implementation Contract

Use Harmony's current workflow runtime docs plus
`../contracts/cross-surface-reference-contract.md` and
`../contracts/run-linkage-contract.md`.
Also see `../contracts/mission-workflow-binding-contract.md`.
Canonicalization addenda should define machine-readable
`execution_controls.cancel_safe` for workflows that may be preempted by
automation `replace` mode.

## Example Use Cases

1. `create-mission` scaffolds a new mission artifact set and registers it.
2. `audit-continuous-workflow` defines a bounded layered audit with cadence
   metadata, reporting, and a final verification gate.

## Relationships

### Complements Or Supports

- `missions`
- `automations`
- `runs`
- `incidents`

### Depends On

- skills and services
- orchestration authoring standards

### Surfaces Depend On It

- `missions`
- `automations`
- operators
- `incidents` for rollback or containment procedures

### Autonomy Posture

- not self-governing
- not autonomous by itself

### Overlap Risks

- overlaps composite skills if procedural and capability boundaries blur
- overlaps automations if recurrence is embedded in procedure definitions
- overlaps missions if workflow definitions start holding long-lived initiative
  state

## Proposed Canonical Artifacts

```text
workflows/
├── manifest.yml
├── registry.yml
└── <group>/<workflow-id>/
    ├── WORKFLOW.md
    ├── 01-*.md
    ├── ...
    └── NN-verify.md
```

## Non-Goals

- schedule ownership
- portfolio coordination
- long-lived event listening
- incident authority
