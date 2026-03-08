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

Use Harmony's current mission runtime docs plus
`../contracts/cross-surface-reference-contract.md` and
`../contracts/run-linkage-contract.md`.
Also see `../contracts/mission-workflow-binding-contract.md`.

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
    ├── mission.md
    ├── tasks.json
    ├── log.md
    └── context/
```

## Non-Goals

- defining reusable procedures
- owning recurrence policy
- replacing incident state or portfolio coordination
