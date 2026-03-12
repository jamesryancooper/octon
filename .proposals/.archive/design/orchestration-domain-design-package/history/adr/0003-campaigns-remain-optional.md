# ADR 0003: Campaigns Remain Optional

## Status

- accepted

## Context

`campaigns` provide strategic coordination above missions, but they are not part
of the minimal mature core. Making them mandatory would add hierarchy before
mission coordination pressure justifies it.

## Decision

`campaigns` remain optional and must not be promoted unless real coordination
load requires them.

## Consequences

- preserves minimal sufficient complexity
- keeps the mature core small and robust
- avoids strategic overhead when missions are sufficient

## Alternatives Considered

- Make campaigns a core required surface
- Remove campaigns entirely from the model

## Relationship To Existing Contracts

- reinforces `contracts/campaign-object-contract.md`
- reinforces `contracts/campaign-mission-coordination-contract.md`
- aligns with `reference/surface-criticality-and-ranking.md`
