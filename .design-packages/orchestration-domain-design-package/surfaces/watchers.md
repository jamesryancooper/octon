# Surface: Watchers

## Status

- Proposed

## Core Purpose

`watchers` are long-lived detectors that observe signals, evaluate rules or
thresholds, and emit events when a monitored condition matters.

## Responsibilities

- monitor defined sources
- evaluate rules, thresholds, or change patterns
- emit deduplicated events for downstream handling through an explicit event
  contract
- maintain health, cursor, and suppression state

## Differentiators

- detect rather than execute
- long-lived and sensor-like
- upstream of automations, queue, and incidents

## Complexity

- `High`

## Criticality And Ranking

- Criticality: `3/10`
- Usefulness rank: `7`
- Need rank: `7`

## Implementation Contract

See `../contracts/watcher-event-contract.md` and
`../contracts/cross-surface-reference-contract.md`.

## Example Use Cases

1. A watcher that detects stale governance or documentation drift and emits an
   event for a freshness audit.
2. A watcher that monitors CI or runtime gate failures and emits a structured
   incident-trigger candidate.

## Relationships

### Complements Or Supports

- `queue`
- `automations`
- `incidents`

### Depends On

- signal sources
- detection rules
- an explicit emitted-event contract
- often `queue`

### Surfaces Depend On It

- `queue`
- `automations`
- possibly `incidents`

### Autonomy Posture

- functions autonomously within rule boundaries
- not self-governing

### Overlap Risks

- overlaps `automations` if watchers start making launch-policy decisions
- overlaps observability services if they become just another monitoring stack
- overlaps incidents if every detection automatically becomes incident state

## Proposed Canonical Artifacts

```text
watchers/
├── README.md
├── manifest.yml
├── registry.yml
└── <watcher-id>/
    ├── watcher.yml
    ├── sources.yml
    ├── rules.yml
    ├── emits.yml
    └── state/
        ├── cursor.json
        ├── health.json
        └── suppressions.json
```

## Non-Goals

- owning procedure execution
- owning recurrence policy
- replacing run evidence or initiative state
