# Core Comms Guide — Ports, Artifacts, Events, Error Taxonomy

**Octon-aligned.** Monolith-first, hexagonal boundaries, deterministic services. Services communicate via **typed direct calls**, **artifacts/manifests**, and **events**. This guide is the contract for service-to-service comms.

---

## 1) Ports (typed synchronous calls)

### 1.1 Contracts

* **Single source of truth:** JSON Schema 2020-12 per operation.
* **Generated types:** TS (typebox/zod), Python (pydantic v2).
* **Stability:** breaking change ⇒ **major**; additive ⇒ minor; docs/metadata ⇒ patch.

### 1.2 Required call metadata

* `run_id` (string): correlates work across services.
* `traceparent` (W3C): propagate through every boundary.
* `deadline_ms` (int) or `budget.seconds_max` (int): hard limit; service must enforce.
* `idempotency_key` (string): dedupe and safe retries for mutating operations.

### 1.3 Error taxonomy (uniform across services)

Use this exact set in error envelopes:

* `InvalidInput` – schema/validation failed (400)
* `PreconditionFailed` – missing/invalid state (409/412)
* `NotFound` – resource absent (404)
* `Conflict` – concurrent modification / lock held (409)
* `QuotaExceeded` – limits exceeded (429)
* `Unauthorized` / `Forbidden` – authN/Z failures (401/403)
* `Transient` – retryable infra/dep failure (502/503)
* `Internal` – non-retryable bug (500)

**Error envelope**

```json
{
  "error": {
    "code": "PreconditionFailed",
    "message": "Source manifest is missing required file(s)",
    "details": {"missing": ["faiss.index"]},
    "trace_id": "...",
    "run_id": "r_123"
  }
}
```

### 1.4 Example port (TypeScript)

```ts
export interface BuildIndexParams {
  index_name: string;
  source_manifest_uri: string;   // file://, s3://
  run_id: string;
  idempotency_key?: string;
  budget?: { seconds_max?: number; calls_max?: number };
}
export interface BuildIndexResult {
  manifest_uri: string;
  metrics: { docs: number; bytes: number; duration_ms: number };
}
```

---

## 2) Artifacts & Manifests (async-by-design)

### 2.1 Rules of the road

* APIs return **URIs**, not blobs. Move big data via filesystem/object store.
* Every artifact directory has a **`manifest.json`** with checksums and provenance.
* Schema evolution is **append-only**; older consumers must still read new manifests.

### 2.2 Layout (suggested)

```
/runs/<run_id>/inputs/*.jsonl
/runs/<run_id>/outputs/*.jsonl
/indexes/<name>/{manifest.json, *.index, meta.json}
/evidence/<topic>/<YYYYMMDD>/*.json
```

### 2.3 Minimal manifest schema

```json
{
  "$schema": "https://schemas.ai-toolkit.dev/index-manifest-1.json",
  "name": "docs_main",
  "version": "1.2.0",
  "produced_by": "Index",
  "created_at": "2025-11-06T01:00:00Z",
  "run_id": "r_123",
  "contents": [
    {"path": "indexes/docs_main/faiss.index", "sha256": "...", "size_bytes": 1234567},
    {"path": "indexes/docs_main/meta.json",  "sha256": "..."}
  ]
}
```

### 2.4 Integrity & provenance

* **Checksums:** sha256 for each file; verify on read.
* **Content-type:** set when useful (`application/json`, `application/octet-stream`).
* **Provenance:** include tool version, dataset hash, and parameters in `meta.json`.

---

## 3) Events (fan-out, decoupling)

### 3.1 Transport & envelope

* **Bus:** NATS (preferred) or Redis Streams.
* **Envelope:** CloudEvents 1.0 JSON. At-least-once delivery.
* **Idempotency:** consumers must be idempotent; use `id` + dedupe store.

### 3.2 Event types (suggested)

* `plan.created`
* `agent.run.started`
* `artifact.ready`
* `index.updated`
* `query.performed`
* `eval.report.available`
* `patch.pr.opened`

**CloudEvent example**

```json
{
  "specversion": "1.0",
  "type": "ai.toolkit.index.updated",
  "source": "Index",
  "id": "uuid",
  "time": "2025-11-06T01:02:03Z",
  "datacontenttype": "application/json",
  "traceparent": "00-<trace>-<span>-01",
  "data": {
    "index_name": "docs_main",
    "manifest_uri": "file://indexes/docs_main/manifest.json",
    "run_id": "r_123"
  }
}
```

### 3.3 Reliability patterns

* **Retries:** exponential backoff with jitter.
* **DLQ:** per-consumer dead-letter topic with alerting.
* **Ordering:** no global ordering; use `run_id` scoping; persist last processed offset per `run_id` if needed.

---

## 4) Observability & SLOs

* **Tracing:** OpenTelemetry; propagate `traceparent` in ports & events.
* **Logging:** JSON logs with `{ts, level, service, tool, run_id, trace_id, duration_ms}`.
* **Metrics:** counters (`calls_total`, `errors_total`), histograms (`latency_ms`), gauges (`queue_depth`).
* **SLOs:** define per-operation p95 latency and availability; use burn-rate alerts.

---

## 5) Security

* **AuthN/Z:** mTLS for RPC; HMAC/JWS for event signing when crossing boundaries.
* **Least privilege:** per-operation allowlists; default deny.
* **Egress control:** SSRF-harden fetchers; destination allowlist.
* **Secrets:** Vault/OS keyring; never commit to manifests.

---

## 6) Playbooks

* Add an operation → write schema, generate types, implement core, add contract tests, instrument, document.
* Change a schema → additive first; mark `x-deprecated: true`; remove after two minor releases with usage <5%.
* Handle big payloads → return URIs; include range-read support on consumers if necessary.
