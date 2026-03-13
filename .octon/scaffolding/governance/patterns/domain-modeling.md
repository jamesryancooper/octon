---
title: Domain Modeling Guide
description: Applying DDD within Octon’s modulith — bounded contexts, aggregates, invariants, events, and transaction boundaries.
---

# Domain Modeling Guide

Status: Draft stub (capture product domain choices)

## Two‑Dev Scope

- Architectural simplicity: avoid event sourcing/CQRS and distributed transactions. Keep a single primary datastore per slice.
- Events: use in‑process domain events only; postpone buses/streams until scale demands.
- Boundaries: prefer a small number of aggregates with clear invariants; keep cross‑context calls minimal and synchronous.
- Multitenancy: choose one model (typically pooled) and document it; avoid complex isolation patterns until justified.

## Pillars Alignment

- Direction through Validated Discovery: Domain boundaries and invariants keep implementation grounded in validated intent.
- Focus through Absorbed Complexity: Use Complexity Calibration to prefer a modular monolith and in-process events until constraints justify more.
- Velocity through Agentic Automation: Clear bounded contexts let agents scaffold ports/adapters quickly with low coordination overhead.
- Trust through Governed Determinism: Explicit invariants and contracts (DTOs/schemas) make behavior testable and reproducible across adapters.
- Continuity through Institutional Memory and Insight through Structured Learning: Durable domain contracts preserve context and improve future modeling decisions.

See `.octon/cognition/practices/methodology/README.md` for Octon's six pillars.

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

- Comparative landscape: `.octon/cognition/_meta/architecture/comparative-landscape.md`
- Repository blueprint: `.octon/cognition/_meta/architecture/repository-blueprint.md`
- Overview: `.octon/cognition/_meta/architecture/overview.md`
- Methodology overview: `.octon/cognition/practices/methodology/README.md`
- Implementation guide: `.octon/cognition/practices/methodology/implementation-guide.md`
- Layers model: `.octon/cognition/_meta/architecture/layers.md`
- Improve layer: `.octon/cognition/_meta/architecture/layers.md#improve-layer`
- Slices vs layers: `.octon/cognition/_meta/architecture/slices-vs-layers.md`
