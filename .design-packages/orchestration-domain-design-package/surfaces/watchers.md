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

## Consumers

- event router
- operators diagnosing health or suppression behavior
- incident-correlation logic
- event-triggered automations downstream of `queue` ingress

## Differentiators

- detect rather than execute
- long-lived and sensor-like
- upstream of automations, `queue`, and incidents

## Complexity

- `High`

## Criticality And Ranking

- Criticality: `3/10`
- Usefulness rank: `7`
- Need rank: `7`

## Implementation Contract

See:

- `../contracts/watcher-definition-contract.md`
- `../contracts/watcher-event-contract.md`
- `../contracts/cross-surface-reference-contract.md`

## Best-Fit Authority Model

`watchers` are a collection surface with all five authority layers present:

1. discovery
   - `manifest.yml`
2. routing / metadata
   - `registry.yml`
3. definition
   - `watcher.yml`, `sources.yml`, `rules.yml`, `emits.yml`
4. mutable state
   - `state/cursor.json`, `state/health.json`, `state/suppressions.json`
5. evidence
   - emitted event lineage keyed by `event_id`, plus downstream queue /
     decision / incident linkage

The watcher definition layer is machine-readable and authoritative.

Markdown remains subordinate guidance only.

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

Emitted event evidence stays outside `state/`; state snapshots do not replace
event lineage.

## Non-Goals

- owning procedure execution
- owning recurrence policy
- replacing run evidence or initiative state
