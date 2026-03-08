# Surface: Queue

## Status

- Proposed

## Core Purpose

`queue` is the durable intake surface for pending machine-ingest work items,
events, retries, and backpressure.

## Responsibilities

- accept and store pending events or jobs
- define or reference the canonical queue item envelope
- support claim, ack, retry, and dead-letter handling
- preserve ordering or priority where required
- provide backpressure and buffering between detection and execution

## Differentiators

- intake-oriented rather than execution-oriented
- durable but intentionally transient
- machine-work buffer, not human initiative planner

## Complexity

- `Medium`

## Criticality And Ranking

- Criticality: `4/10`
- Usefulness rank: `6`
- Need rank: `6`

## Implementation Contract

See `../contracts/queue-item-and-lease-contract.md` and
`../contracts/cross-surface-reference-contract.md`.

## Example Use Cases

1. A queue of freshness or drift events emitted by watchers and claimed by
   automations.
2. A buffered set of pending release-readiness checks triggered by repository
   events so they can be processed with explicit retry and dead-letter behavior.

## Relationships

### Complements Or Supports

- `watchers`
- `automations`

### Depends On

- event producers such as `watchers`
- consumers such as `automations`
- a stable item schema and lease semantics

### Surfaces Depend On It

- `automations`
- operators when manual requeue or dead-letter inspection is needed

### Autonomy Posture

- not self-governing
- can operate autonomously as infrastructure, but does not make policy
  decisions

### Overlap Risks

- overlaps `tasks.json` if human planning is pushed into a machine queue
- overlaps `runs` if queue items are treated as execution receipts
- overlaps `incidents` if dead-letter items are treated as active incident state

## Proposed Canonical Artifacts

```text
queue/
├── README.md
├── registry.yml
├── schema.yml
├── pending/
├── claimed/
├── retry/
├── dead-letter/
└── receipts/
```

## Non-Goals

- portfolio planning
- bounded procedure definition
- direct mission targeting
- replacing continuity task tracking

## Additional Boundary Rule

`queue` is automation-ingress only. Missions may be created downstream by
workflows or incident response, but they do not directly claim queue items.
