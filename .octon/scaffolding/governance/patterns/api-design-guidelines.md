---
title: API Design Guidelines
description: Contract‑first HTTP API guidelines — versioning, pagination, idempotency, error envelopes, timeouts, and compatibility.
---

# API Design Guidelines

Status: Draft stub (confirm defaults and envelopes)

## Two‑Dev Scope

- Make singular repo‑wide choices and stick to them (one pagination strategy, one error envelope, one idempotency approach, one versioning scheme).
- Avoid advanced patterns until needed: no HATEOAS, content negotiation, GraphQL, streaming, or custom middleware frameworks. Keep REST simple.
- Testing: validate with JSON Schema in CI. Add Pact only for external consumers or shared inter‑app boundaries; run Schemathesis on a schedule (not every PR) for stable endpoints.
- Tooling: prefer codegen from OpenAPI for types; avoid introducing an API gateway or service mesh for now.

## Pillars Alignment

- Direction through Validated Discovery: Contract-first APIs keep implementation aligned with validated intent.
- Focus through Absorbed Complexity: Apply Complexity Calibration to keep pagination, errors, timeouts, and retries standardized and minimal sufficient.
- Velocity through Agentic Automation: Stable contracts accelerate automated diff/test generation and safe iteration speed.
- Trust through Governed Determinism: OpenAPI/JSON Schema validation, Pact, and Schemathesis enforce deterministic compatibility.
- Continuity through Institutional Memory and Insight through Structured Learning: Explicit API contracts and test evidence preserve integration history and improve future design choices.

See `.octon/cognition/practices/methodology/README.md` for Octon's six pillars.

## Principles

- Contract‑first with OpenAPI/JSON Schema; validate in CI.
- Backwards compatibility by default; additive changes preferred.

## Core Rules

- Versioning: semantic; avoid breaking changes without major version or negotiated compatibility.
- Pagination: choose `cursor` or `page/page_size` (document once repo‑wide).
- Idempotency: require `Idempotency-Key` on mutating endpoints; dedupe and return prior result on repeat.
- Errors: `{ error: { code, message, details? } }` with stable codes.
- Timeouts/retries: set per adapter; avoid unbounded retries; bubble clear status upstream.
- Rate limiting: document limits and headers if applicable.

## Testing

- Contract tests (Pact) and fuzz/negative (Schemathesis) are mandatory.

## Related Docs

- Contracts/examples: `packages/contracts/`
- Governance gates: `.octon/cognition/_meta/architecture/governance-model.md`
- Methodology overview: `.octon/cognition/practices/methodology/README.md`
- Implementation guide: `.octon/cognition/practices/methodology/implementation-guide.md`
- Layers model: `.octon/cognition/_meta/architecture/layers.md`
- Improve layer: `.octon/cognition/_meta/architecture/layers.md#improve-layer`
- Architecture overview: `.octon/cognition/_meta/architecture/overview.md`
- Tooling integration: `.octon/cognition/_meta/architecture/tooling-integration.md`
