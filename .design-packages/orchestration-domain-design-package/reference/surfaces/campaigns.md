# Surface: Campaigns

## Status

- Proposed
- optional by design; promote only when multi-mission coordination pressure
  justifies the extra surface

## Core Purpose

`campaigns` are optional strategic coordination objects for multiple related
missions serving one larger objective.

## Responsibilities

- define the shared objective across multiple missions
- maintain machine-readable campaign identity, lifecycle, mission membership,
  and milestones
- capture cross-mission dependencies, waivers, and residual portfolio risks
- expose rollup status for operator review without becoming an execution
  surface

## Consumers

- operators coordinating multiple related missions
- planning or closeout workflows that need bounded portfolio context
- reporting and promotion tooling that needs deterministic campaign rollups

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

See:

- `../contracts/campaign-object-contract.md`
- `../contracts/campaign-mission-coordination-contract.md`
- `../contracts/discovery-and-authority-layer-contract.md`
- `../contracts/cross-surface-reference-contract.md`

## Best-Fit Authority Model

`campaigns` are an optional coordination-object collection surface with a
single canonical machine-readable object per campaign:

1. discovery
   - `manifest.yml`
2. routing / metadata
   - `registry.yml`
3. canonical object and current coordination state
   - `<campaign-id>/campaign.yml`
4. separate mutable state layer
   - none in v1; current campaign state lives in `campaign.yml`
5. evidence / operator narrative
   - `<campaign-id>/log.md` plus linked mission, decision, run, or incident
     evidence

Why this shape fits `campaigns`:

- campaigns carry stateful coordination data that other actors must read
  deterministically
- campaigns are not execution-bearing controllers, so a separate `state/`
  subtree would add complexity without creating a real authority seam
- Markdown remains useful for rationale and portfolio notes, but it should not
  be the canonical source for lifecycle status, mission membership, milestones,
  or waivers

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
    ├── campaign.yml
    └── log.md
```

`campaign.yml` is the canonical machine-readable campaign record.
`log.md` is subordinate append-oriented coordination context.

## Non-Goals

- direct workflow execution
- schedule ownership
- incident response ownership
- replacing mission-local state or run evidence
