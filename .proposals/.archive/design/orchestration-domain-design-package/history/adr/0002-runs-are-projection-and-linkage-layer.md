# ADR 0002: Runs Are Projection And Linkage Layer

## Status

- accepted

## Context

Octon already uses `continuity/runs/` as append-oriented durable evidence.
The mature orchestration model introduces `runs/` as a first-class runtime
surface. Without a clear split, evidence would be duplicated or drift.

## Decision

`runs/` is an orchestration-facing projection and linkage layer. Durable
evidence remains in `continuity/runs/`.

## Consequences

- preserves single source of truth for durable evidence
- makes operator lookup easier without duplicating evidence payloads
- keeps runtime state mutable and continuity evidence append-oriented

## Alternatives Considered

- Store all evidence directly in runtime `runs/`
- Use only continuity evidence and no runtime run projection

## Relationship To Existing Contracts

- reinforces `contracts/run-linkage-contract.md`
- reinforces `contracts/discovery-and-authority-layer-contract.md`
- aligns with `reference/runtime-shape-and-directory-structure.md`
