---
title: Terminology — Slices vs Layers
description: Clarifies that runtime code is organized by vertical feature slices; “layers” refers only to cross-cutting governance/control planes.
---

# Terminology: Slices vs Layers

- Runtime code is organized by vertical feature slices with hexagonal (ports/adapters) boundaries. We do not use classic n‑tier layering for application calls.
- “Layer” refers to cross‑cutting governance/control‑plane concerns (e.g., Kaizen, quality gates, observability, security) that span slices.
- Prefer ports/adapters within each slice to keep the domain core technology‑agnostic and testable.

Physically, vertical slices live under `packages/<feature>` and follow a hexagonal structure:

- `packages/<feature>/domain/` — pure domain/use-cases (no IO, no framework dependencies).
- `packages/<feature>/adapters/` — outbound adapters (DB/HTTP/cache) that depend inward on domain ports.
- `packages/<feature>/api/` — inbound interfaces/contracts; HTTP APIs are expressed as OpenAPI/JSON Schema in the root `contracts/` registry.
- `packages/<feature>/tests/` — unit/integration/contract tests for the slice.

Slice-level HTTP contracts are defined in `contracts/openapi` and `contracts/schemas` and generate TypeScript and Python clients in `contracts/ts` and `contracts/py` for consumers across planes. See [contracts registry](./contracts-registry.md) and [monorepo polyglot](./monorepo-polyglot.md) for the canonical layout.

See also: [overview](./overview.md), [layers overview](./layers.md), [monorepo layout](./monorepo-layout.md), and [repository blueprint](./repository-blueprint.md).
