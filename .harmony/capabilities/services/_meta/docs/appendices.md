# Shared Appendices — Glossary, Schema Catalog, SLOs, ADR Links

These appendices are referenced by **Comms Guide**, **Agent Guide**, and **MCP Guide**. Keep them DRY and versioned.

---

## A) Glossary

- **Agent** — A thin policy that sequences service operations where judgment is needed.
- **Agent (service)** — The orchestrator implementing agent policies, budgets, and telemetry, built on top of Flow and the shared LangGraph runtime; it consumes Plan `plan.json` plans and drives flows via Flow.
- **Artifact** — A durable file/object produced/consumed by services (e.g., indexes, evidence packs).
- **CloudEvents** — CNCF event envelope used on the event bus.
- **Comms Stack** — Ports (typed calls), Artifacts (URIs/manifests), Events (CloudEvents).
- **Hexagonal Architecture** — Ports (core interfaces) + Adapters (HTTP/MCP/etc.).
- **Idempotency Key** — Caller-provided token allowing safe retries of mutating ops.
- **Service** — Deterministic capability exposing typed interfaces (the building blocks).
- **Manifest** — JSON file listing artifact contents, checksums, provenance.
- **MCP** — Model Context Protocol; adapter exposing service ops as tools/resources over stdio/wss.
- **Run ID** — Correlation id for a workflow spanning multiple services.
- **SLO** — Service Level Objective; target for latency/availability.
- **Trace Context** — W3C `traceparent` header propagated across calls/events.

---

## B) Schema Catalog

### B.1 Location & layout

- **Repository:** `schemas/` at repo root or a dedicated schemas repo.
- **Structure:**

```text
schemas/
  services/
    index/
      build.v1.json
      compact.v1.json
    ingest/
      load.v1.json
  artifacts/
    index-manifest-1.json
  errors/
    envelope.v1.json
```

### B.2 Versioning & naming

- File name pattern: `<operation>.v<major>.json` (major follows SemVer for breaking changes).
- Use `$id` and `$schema` fields; include `examples` and `x-deprecated` where applicable.

### B.3 Tooling

- **Validation:** AJV (TS) / pydantic v2 (Py) in CI.
- **Generation:** typebox/zod (TS) and pydantic models (Py) generated from schemas.
- **Docs:** auto-render schema docs (e.g., Redocly or custom script) to `/docs/schemas`.

---

## C) SLO Templates & Monitoring

### C.1 Per-operation SLOs

- **Availability:** 99.9% monthly (or as defined per service).
- **Latency:** p95 ≤ target (e.g., 500 ms for small queries; service-specific for heavy ops).
- **Error budget policy:**

  - 2-window burn-rate alerts (e.g., 2h at 14x, 24h at 6x).
  - Freeze risky deploys when burn-rate sustained for >30 min.

**SLO YAML (example):**

```yaml
service: index.build
availability:
  objective: 99.9
  window: 30d
latency:
  p95_ms: 500
  window: 7d
alerts:
  burn_rate:
    - window: 2h
      factor: 14
    - window: 24h
      factor: 6
```

### C.2 Metrics cardinality guardrails

- Dimensions: `service`, `tool/op`, `caller`, `code`, `region` (bounded sets only).
- Avoid unbounded labels (e.g., `run_id`) on metrics; put those in logs/traces.

---

## D) ADR (Architecture Decision Records)

### D.1 Where ADRs live

- `docs/adr/` in the monorepo or a dedicated ADR repo; each ADR is immutable after `Accepted`.

### D.2 Template

```markdown
# ADR-YYYYMMDD-<slug>

## Status
Proposed | Accepted | Superseded by ADR-...

## Context
(Problem statement, constraints, stakeholders.)

## Decision
(Chosen option and why.)

## Consequences
(Positive/negative effects, follow-ups.)

## Alternatives Considered
(A, B, C with brief pros/cons.)
```

### D.3 Seed ADRs (suggested)

- ADR-0001: Monolith-first with hexagonal boundaries (Harmony)
- ADR-0002: Comms stack = Ports + Artifacts + Events (no blob RPC)
- ADR-0003: CloudEvents envelope on NATS
- ADR-0004: JSON Schema as contract; codegen for TS/Py
- ADR-0005: MCP as provider adapter; return URIs for large data
- ADR-0006: Error taxonomy (v1)
- ADR-0007: SLOs and burn-rate policy

---

## E) Cross-references

- **Comms Guide:** definitions for ports, manifests, events, security.
- **Agent Guide:** policies, guardrails, budgets, eval.
- **MCP Guide:** tool/resource mapping, security, compatibility.

**Note:** update cross-links on every minor version bump; keep a compatibility matrix at the top of each guide.
