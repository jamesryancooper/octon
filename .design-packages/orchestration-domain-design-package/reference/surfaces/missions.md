# Surface: Missions

## Status

- Current Harmony surface

## Core Purpose

`missions` are bounded multi-session initiatives with explicit ownership,
success criteria, and isolated progress tracking.

## Responsibilities

- hold initiative-level goal and scope
- maintain owner, status, success criteria, and lifecycle
- isolate mission-specific tasks and progress logs
- coordinate multiple workflow runs across a bounded effort

## Differentiators

- broader than a workflow, narrower than a campaign
- stateful and bounded over time
- initiative-oriented rather than procedure-oriented

## Complexity

- `Medium`

## Criticality And Ranking

- Criticality: `8/10`
- Usefulness rank: `2`
- Need rank: `2`

## Implementation Contract

Primary orchestration behavior for `missions` in this package is defined by:

- `normative/architecture/domain-model.md`
- `normative/execution/orchestration-execution-model.md`
- `normative/execution/orchestration-lifecycle.md`
- `normative/governance/governance-and-policy.md`
- `../contracts/cross-surface-reference-contract.md`
- `../contracts/mission-object-contract.md`
- `../contracts/run-linkage-contract.md`
- `../contracts/mission-workflow-binding-contract.md`
- `normative/assurance/surface-artifact-schemas.md`

Live Harmony mission docs remain integration context for the current runtime
surface shape. They are not the primary source of target cross-surface
orchestration behavior here.

## Example Use Cases

1. An `acp-migration-cleanup` mission that spans several workflow runs,
   validation passes, and continuity updates over multiple sessions.
2. A `release-readiness-harden-capabilities` mission that owns a bounded release
   push for one subsystem with explicit success criteria.

## Relationships

### Complements Or Supports

- `workflows`
- `runs`
- `incidents`
- optional `campaigns`

### Depends On

- `workflows`
- continuity state
- optionally `runs` for execution traceability

### Surfaces Depend On It

- `campaigns` may aggregate missions
- operators and automations may target mission context

### Autonomy Posture

- not self-governing
- can be agent-owned, but remains governed by explicit scope and lifecycle

## Target Authority Model

- `registry.yml`
  - discovery and lifecycle projection only
- `<mission-id>/mission.yml`
  - canonical machine-readable mission object for identity, lifecycle,
    ownership, success criteria, and cross-surface linkage
- `<mission-id>/mission.md`
  - optional human-readable brief subordinate to `mission.yml`
- `tasks.json` and `context/`
  - mutable mission-local planning state and blockers
- `log.md` plus linked runs / continuity evidence
  - append-oriented mission-local narrative and cross-surface evidence pointers

### Overlap Risks

- overlaps `tasks.json` if used for generic project task tracking
- overlaps `campaigns` if used for portfolio-level coordination
- overlaps `incidents` if incident remediation is not separated from incident
  state

## Proposed Canonical Artifacts

```text
missions/
├── registry.yml
├── .archive/
└── <mission-id>/
    ├── mission.yml
    ├── mission.md
    ├── tasks.json
    ├── log.md
    └── context/
```

`mission.yml` is required.

`mission.md` is optional but recommended and must remain subordinate to
`mission.yml`.

## Non-Goals

- defining reusable procedures
- owning recurrence policy
- replacing incident state or portfolio coordination
