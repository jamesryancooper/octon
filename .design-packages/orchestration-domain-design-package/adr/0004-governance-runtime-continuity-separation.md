# ADR 0004: Governance Runtime And Continuity Separation Must Remain Explicit

## Status

- accepted

## Context

Harmony’s operating model depends on explicit boundary separation. If runtime
state, governance policy, and continuity evidence collapse into one layer, the
system becomes harder to trust, validate, and evolve.

## Decision

The orchestration domain preserves explicit separation between:

- `runtime/` for active executable or stateful surfaces
- `governance/` for authority and policy
- `practices/` for authoring and operating discipline
- `continuity/` for append-oriented evidence and handoff memory

## Consequences

- strengthens traceability and reviewability
- preserves fail-closed routing and policy enforcement
- prevents runtime artifacts from silently becoming policy

## Alternatives Considered

- Collapsing policy into runtime surface definitions
- Using continuity as the live source of orchestration state

## Relationship To Existing Contracts

- reinforces `contracts/discovery-and-authority-layer-contract.md`
- reinforces `contracts/run-linkage-contract.md`
- aligns with `example-orchestration-charter.md`
