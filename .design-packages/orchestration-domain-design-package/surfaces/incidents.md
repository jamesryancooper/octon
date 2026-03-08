# Surface: Incidents

## Status

- Governance guidance exists today
- runtime incident state is proposed only if incident operations become more
  active and object-oriented

## Core Purpose

`incidents` are the operational override surface for abnormal conditions that
require containment, escalation, rollback, mitigation, and closure evidence.

## Responsibilities

- track incident identity, status, severity, owner, and timeline
- link incident state to exact runs, workflows, and missions
- coordinate containment, rollback, and remediation pathways
- record closure rationale and residual follow-up work

## Differentiators

- exception-focused rather than routine execution-focused
- safety and containment surface rather than delivery surface
- explicitly operator-visible and escalation-aware

## Complexity

- `High`

## Criticality And Ranking

- Criticality: `5/10`
- Usefulness rank: `5`
- Need rank: `4`

## Implementation Contract

See `../contracts/incident-object-contract.md` and
`../contracts/cross-surface-reference-contract.md`.

## Example Use Cases

1. A production regression incident that links to the failing run, launches a
   rollback workflow, and creates a remediation mission.
2. A governance-gate failure incident that captures blocked release state,
   evidence, human escalation, and final closure.

## Relationships

### Complements Or Supports

- `runs`
- `workflows`
- `missions`

### Depends On

- `runs`
- incident governance policy
- containment or rollback workflows

### Surfaces Depend On It

- none in normal-path execution
- operators and remediation processes depend on it during abnormal conditions

### Autonomy Posture

- not self-governing
- should remain human-governed even if some containment actions can be
  automated

### Overlap Risks

- overlaps `missions` if remediation work is mixed into incident state
- overlaps `queue` if incidents are treated as generic intake objects
- overlaps governance docs if runtime incident state is used as implicit policy

## Proposed Canonical Artifacts

```text
incidents/
├── README.md
├── manifest.yml
├── registry.yml
└── <incident-id>/
    ├── incident.md
    ├── timeline.md
    ├── actions.yml
    ├── linked-runs.yml
    └── closure.md
```

## Non-Goals

- generic task management
- replacing mission planning
- self-authorizing policy exceptions
