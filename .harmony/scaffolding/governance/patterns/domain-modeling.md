---
title: Domain Modeling Guide
description: Applying DDD within Harmony’s modulith — bounded contexts, aggregates, invariants, events, and transaction boundaries.
---

# Domain Modeling Guide

Status: Draft stub (capture product domain choices)

## Two‑Dev Scope

- Architectural simplicity: avoid event sourcing/CQRS and distributed transactions. Keep a single primary datastore per slice.
- Events: use in‑process domain events only; postpone buses/streams until scale demands.
- Boundaries: prefer a small number of aggregates with clear invariants; keep cross‑context calls minimal and synchronous.
- Multitenancy: choose one model (typically pooled) and document it; avoid complex isolation patterns until justified.

## Pillars Alignment

- Speed with Safety: Vertical slices and bounded contexts reduce blast radius, enabling small, reversible changes with clear ownership.
- Simplicity over Complexity: Prefer a modular monolith and in‑process domain events before adding infrastructure or choreography.
- Quality through Determinism: Explicit invariants and contracts (DTOs/schemas) make behavior testable and reproducible across adapters.
- Guided Agentic Autonomy: Agents can scaffold ports/adapters from contracts; humans verify invariants and approve domain changes.

See `.harmony/cognition/practices/methodology/README.md` for Harmony’s five pillars.

## Scope

- Structure slices as bounded contexts; keep domain pure; adapters implement ports.

## Core Guidance

- Aggregates: define invariants and transaction boundaries; avoid chatty cross‑aggregate calls.
- Events: use explicit domain events for cross‑context interactions where useful; prefer simple in‑process publication initially.
- Data ownership: a slice owns its schema; share via contracts/DTOs.
- Multitenancy: choose model (pooled/partitioned) and document per slice.

## Enforcement

- Enforce boundaries via lint/dependency checks; see repository blueprint.

## Related Docs

- Comparative landscape: `.harmony/cognition/_meta/architecture/comparative-landscape.md`
- Repository blueprint: `.harmony/cognition/_meta/architecture/repository-blueprint.md`
- Overview: `.harmony/cognition/_meta/architecture/overview.md`
- Methodology overview: `.harmony/cognition/practices/methodology/README.md`
- Implementation guide: `.harmony/cognition/practices/methodology/implementation-guide.md`
- Layers model: `.harmony/cognition/practices/methodology/layers.md`
- Improve layer: `.harmony/cognition/practices/methodology/improve-layer.md`
- Slices vs layers: `.harmony/cognition/_meta/architecture/slices-vs-layers.md`
