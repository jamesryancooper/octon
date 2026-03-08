# Surface: Campaigns

## Status

- Proposed

## Core Purpose

`campaigns` are strategic containers for multiple related missions that serve
one larger objective.

## Responsibilities

- define the shared objective across multiple missions
- track milestones and portfolio-level status
- capture cross-mission dependencies and risks
- roll up outcomes for operator review

## Differentiators

- broader than a mission
- non-executable by itself
- strategic rather than procedural

## Complexity

- `Medium`

## Criticality And Ranking

- Criticality: `2/10`
- Usefulness rank: `8`
- Need rank: `8`

## Implementation Contract

See `../contracts/campaign-object-contract.md`.
Also see `../contracts/campaign-mission-coordination-contract.md`.

## Example Use Cases

1. A `harness-portability-2026` campaign that groups missions for bootstrap
   cleanup, runtime portability, and validation standardization.
2. A `governance-hardening` campaign that groups missions for contract cleanup,
   assurance tightening, and incident response alignment.

## Relationships

### Complements Or Supports

- `missions`
- `runs`
- `incidents`

### Depends On

- `missions`

### Surfaces Depend On It

- none as a hard dependency

### Autonomy Posture

- not self-governing
- not an autonomous execution surface

### Overlap Risks

- can overlap `missions` if missions are allowed to grow too broad
- can overlap human planning artifacts if used as a generic roadmap store

## Proposed Canonical Artifacts

```text
campaigns/
├── README.md
├── manifest.yml
├── registry.yml
└── <campaign-id>/
    ├── campaign.md
    ├── milestones.yml
    ├── missions.yml
    └── log.md
```

## Non-Goals

- direct workflow execution
- schedule ownership
- incident response ownership
