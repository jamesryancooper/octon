---
title: "ADR-013: Filesystem Interfaces Native-First Interface"
description: Add a native filesystem and derived knowledge-graph service contract for progressive discovery and provenance-backed traversal.
status: accepted
date: 2026-02-15
---

# ADR-013: Filesystem Interfaces Native-First Interface

## Context

Harmony needs stronger agent-side retrieval, impact tracing, and progressive discovery
across files and derived relationships. Existing services provide retrieval and query
primitives but do not expose a unified filesystem + graph operation surface.

## Decision

Adopt contract-first filesystem interfaces under the split runtime planes:
`.harmony/capabilities/services/interfaces/filesystem-snapshot/`,
`.harmony/capabilities/services/interfaces/filesystem-discovery/`, and
`.harmony/capabilities/services/interfaces/filesystem-watch/`, with these rules:

1. Files remain source-of-truth.
2. Snapshot artifacts are deterministic and immutable.
3. Graph state is derived, never canonical truth.
4. Core contracts are provider-agnostic and native-first.
5. Progressive discovery operations (`start`, `expand`, `explain`, `resolve`) are first-class.

## Rationale

- Improves agent efficiency and context-budget discipline via progressive disclosure.
- Preserves reversibility by keeping contracts stable and backend-agnostic.
- Enables optional accelerator backends without contract churn.
- Aligns with existing native-first and fail-closed governance posture.

## Consequences

### Positive

- Unified operation surface for filesystem, snapshot, graph, and discovery.
- Deterministic artifacts support repeatable analysis and auditability.
- Strong provenance mapping from graph entities to concrete files.

### Costs

- Additional service contracts, scripts, and validation maintenance.
- Snapshot-build runtime overhead on large trees.

## Alternatives Considered

1. Query-only approach with no dedicated filesystem interfaces.
- Rejected: graph and filesystem semantics remain fragmented.

2. Graph database as canonical source.
- Rejected: violates file source-of-truth model and increases operational coupling.

3. External platform-owned API layer.
- Rejected: weakens native-first contract and long-term portability.

## Implementation Notes

- Context contract:
  - `.harmony/cognition/context/filesystem-interfaces-interop.md`
- Service contracts:
  - `.harmony/capabilities/services/interfaces/filesystem-snapshot/`
  - `.harmony/capabilities/services/interfaces/filesystem-discovery/`
  - `.harmony/capabilities/services/interfaces/filesystem-watch/`
- Plan:
  - Historical execution plan in `.harmony/output/plans/`
