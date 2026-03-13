# Surface: Workflows

## Status

- Current Octon surface

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

Primary orchestration behavior for `workflows` in this package is defined by:

- `normative/architecture/domain-model.md`
- `normative/execution/orchestration-execution-model.md`
- `normative/execution/orchestration-lifecycle.md`
- `normative/governance/governance-and-policy.md`
- `../contracts/workflow-execution-contract.md`
- `../contracts/cross-surface-reference-contract.md`
- `../contracts/run-linkage-contract.md`
- `../contracts/mission-workflow-binding-contract.md`

Live Octon workflow docs remain important integration context for the current
runtime surface shape. They are not the primary source of target
cross-surface orchestration behavior here.

Canonicalization addenda should keep `workflow.yml` as the machine-readable
definition contract and keep Markdown limited to subordinate stage assets and
human guidance.

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

## Authority Model

- discovery
  - `manifest.yml`
- routing and metadata
  - `registry.yml`
- definition
  - `<group>/<workflow-id>/workflow.yml`
- executor-facing instruction assets
  - `<group>/<workflow-id>/stages/*.md`
- human guidance
  - `<group>/<workflow-id>/README.md`
- state and evidence
  - `runtime/runs/` plus `continuity/runs/`

`workflow.yml` is authoritative for version, inputs, stage graph, artifacts,
and execution controls. `README.md` is never the canonical execution contract.

## Proposed Canonical Artifacts

```text
workflows/
├── manifest.yml
├── registry.yml
└── <group>/<workflow-id>/
    ├── workflow.yml
    ├── stages/
    │   ├── 01-*.md
    │   ├── ...
    │   └── 99-verify.md
    └── README.md
```

## Non-Goals

- schedule ownership
- portfolio coordination
- long-lived event listening
- incident authority
