# ADR 0001: Queue Is Automation Ingress Only

## Status

- accepted

## Context

The package introduces `queue` as part of the event-driven scale layer. Without
an explicit boundary, queue items could drift into direct mission targeting or
human planning semantics, which would blur routing and initiative ownership.

## Decision

`queue` is automation-ingress only.

Queue items target exactly one automation. Missions may be created downstream by
workflows or incident response, but they do not directly claim queue items.

## Consequences

- keeps ingestion and initiative ownership separate
- simplifies deterministic routing
- prevents `queue` from becoming a second task system

## Alternatives Considered

- Direct mission targeting from queue
- Mixed automation/mission queue consumers

## Relationship To Existing Contracts

- reinforces `contracts/queue-item-and-lease-contract.md`
- reinforces `contracts/cross-surface-reference-contract.md`
- aligns with `layered-model.md`
