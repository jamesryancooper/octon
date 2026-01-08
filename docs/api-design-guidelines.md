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

- Speed with Safety: Contract‑first APIs enable rapid, reversible iterations; idempotency keys make retries safe and predictable during deploys and rollbacks.
- Simplicity over Complexity: A single repo‑wide approach to pagination, error envelopes, timeouts, and retries reduces cognitive load and integration friction.
- Quality through Determinism: OpenAPI/JSON Schema validated in CI, plus Pact and Schemathesis, prevent drift and enforce backwards compatibility.
- Guided Agentic Autonomy: Machine‑checkable contracts allow agents to propose diffs and generate tests; humans approve. Pin AI configs and link ObservaKit traces for agent‑assisted changes.

See `docs/methodology/README.md` for Harmony’s five pillars.

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
- Governance gates: `docs/architecture/governance-model.md`
- Methodology overview: `docs/methodology/README.md`
- Implementation guide: `docs/methodology/implementation-guide.md`
- Layers model: `docs/methodology/layers.md`
- Improve layer: `docs/methodology/improve-layer.md`
- Architecture overview: `docs/architecture/overview.md`
- Tooling integration: `docs/architecture/tooling-integration.md`
