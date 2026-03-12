# Surface: Incidents

## Status

- Governance guidance exists today
- runtime incident state is proposed only if incident operations become more
  active and object-oriented
- when promoted, runtime incident state should use a schema-backed response
  object model rather than Markdown-first per-incident folders

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

## Authority Model

- `incident.yml` is the canonical machine-readable incident object and mutable
  state authority
- `actions.yml` is the optional machine-readable coordination layer for
  containment, rollback, remediation, or review actions
- `timeline.md` and `closure.md` are subordinate evidence and operator
  guidance, not execution authority
- governance severity and closure authority still come from live incident
  governance policy, not from runtime incident objects alone

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
├── index.yml
└── <incident-id>/
    ├── incident.yml
    ├── actions.yml
    ├── timeline.md
    └── closure.md
```

Why this shape fits `incidents`:

- incidents are runtime-created response records, so a canonical per-incident
  object is more appropriate than a collection-surface manifest/registry split
- status, severity, ownership, linkage, and closure metadata must be
  machine-readable to support fail-closed behavior and deterministic promotion
- narrative timeline and closure summaries remain valuable, but they should be
  evidence attached to the incident object rather than the object authority
  itself

## Non-Goals

- generic task management
- replacing mission planning
- self-authorizing policy exceptions
