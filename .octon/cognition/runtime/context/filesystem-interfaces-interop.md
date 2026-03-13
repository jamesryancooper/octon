---
title: Filesystem Interfaces Interop Contract
description: Native-first contract for filesystem and derived knowledge-graph operations.
---

# Filesystem Interfaces Interop Contract

## Purpose

Define canonical Octon semantics for filesystem operations, deterministic snapshot
lifecycle, derived graph traversal, progressive discovery workflows, and optional watcher hints.

## Contract Version

- `filesystem_interfaces_contract_version`: `1.0.0`
- Effective date: `2026-02-15`

## Native-First Invariants

1. File content and paths are source-of-truth.
2. Graph state is derived from snapshot artifacts.
3. Core operations must run with zero external adapters.
4. Provider-specific terms are disallowed in core filesystem interface contracts.
5. Critical policy failures are fail-closed.
6. Runtime planes are split for operability: writer (`filesystem-snapshot`), query (`filesystem-discovery`), and optional watcher hints (`filesystem-watch`).

## Ownership Boundary

| Capability | Octon Core Owns | Optional Adapter Owns |
|---|---|---|
| Filesystem semantics | Path normalization, read/list/stat/search contracts | Backend-specific storage mapping |
| Snapshot semantics | Deterministic artifact shape, active snapshot pointer | Backend-specific acceleration caches |
| Graph semantics | Node/edge schema, traversal contracts, provenance | Alternative graph traversal engines |
| Discovery semantics | Progressive disclosure contract and deterministic boundaries | Provider-specific ranking augmentation |
| Watch semantics | OS-agnostic bounded polling hints + cursor state contracts | Platform-native watch accelerators (optional) |
| Governance semantics | ACP and no-silent-apply for writes, fail-closed policy | Platform-specific approval plumbing |

## Canonical Semantics

### Snapshot Model

- Snapshot artifacts are immutable once written.
- Active snapshot pointer is explicit (`current`).
- Snapshot artifacts MUST include provenance fields sufficient to resolve to path and hash.

### Graph Model

- Node IDs are stable per snapshot.
- Edge types are typed and explicit.
- Every node and edge must be attributable to source evidence.

### Progressive Discovery

- `discover.start` returns a bounded initial frontier.
- `discover.expand` deepens scope based on explicit frontier IDs.
- `discover.resolve` maps graph entities back to concrete file paths.
- `discover.explain` returns reason and provenance references.

## Fail-Closed Rules

1. Missing or invalid snapshot manifest: block graph operations.
2. Invalid path outside workspace boundary: block operation.
3. Missing required fields in service I/O: return typed validation error.
4. Any unresolved governance requirement for mutating operations: block operation.

## Required Evidence Artifacts

- Phase baseline report in `.octon/output/reports/analysis/` for filesystem interfaces rollout.
- Runtime alignment report in `.octon/output/reports/analysis/` for split snapshot/discovery/watch services.
- Completion evidence report in `.octon/output/reports/analysis/` with validation outcomes.
