# Developer Guide — Comms Stack & Agent Layer (Harmony)

**Audience:** engineers building/operating the AI Services Platform services and the Agent layer.
**Scope:** how services talk to each other today, how agents orchestrate work, and how to expose services as MCP providers—while staying true to the Harmony Lean AI Accelerated Methodology.

---

## TL;DR (what changes, what doesn't)

Unchanged (keep these as your defaults):

* Sync in-process calls: services call ports with JSON-Schema'd I/O and generated types.
* Artifacts for big payloads: pass paths/manifests (evidence packs, indexes) instead of blobs.
* Events for fan-out: CloudEvents on NATS/Redis Streams for index/artifact updates, etc.

Added (when agents use services as tools):

* MCP provider per service (adapter facade) via stdio (local/dev) or wss (remote).
* Tools map 1:1 to service ops; params/results reuse your JSON Schemas.
* Resources expose artifact URIs (file://, s3://) and are fetched via resources.read (support ranges).
* Capability handshake advertises versioned features/limits for safe negotiation.

## 1) Harmony-aligned principles (you'll see these threads everywhere)

* **Monolith-first, hexagonal boundaries.** Keep logic inside the process; place clean ports at the edges. Adapters may multiply; core stays small and boring.
* **Deterministic services first.** Services are typed, idempotent capabilities with predictable side-effects.
* **Artifacts over chatter.** Large payloads travel as files/objects with manifests; APIs pass **pointers**, not blobs.
* **Events for fan-out, not RPC.** CloudEvents envelope; at-least-once; idempotent handlers.
* **Testability and gates.** Contracts in JSON Schema; consumer-driven tests; CI gates before anything ships.
* **SLOs before scale.** Define and watch availability/latency budgets early.
* **Security by default.** mTLS, token scopes, least-privilege, egress controls, SSRF hardening on fetchers.

---

## 2) System at a glance

```text
[ Agent(s) ]
    │   (MCP client)
    ▼
┌────────────────┐   direct typed calls   ┌───────────────┐
│     Agent      │────────────────────────▶│  Service(s)   │
└────────────────┘                         └───────────────┘
        │   (MCP over stdio/wss)                    ▲
        ▼                                           │
┌──────────────────┐   adapter to core   ┌──────────┴─────────┐
│   MCP Provider   │────────────────────▶│   Service Core     │
└──────────────────┘                    └─────────────────────┘
        │                                      │
        │ resources (URIs)                     │ artifacts + events
        ▼                                      ▼
 object store / disk                      manifests + CloudEvents (NATS/Redis)
```

---

## 3) Communication modes

### 3.1 Synchronous typed calls (default inside the monolith)

**When:** same process/container, or low-latency cross-service within the trust boundary.

* **Contract:** JSON Schema 2020-12 is the single source of truth.
* **Types:** generate TS (typebox/zod) and Python (pydantic v2) from the schema.
* **Context:** propagate `trace_id`, `span_id`, `run_id` via W3C Trace Context (aka `traceparent`).
* **Timeouts & budgets:** each call accepts `deadline_ms` and/or `{seconds_max, calls_max}` budget hints.
* **Idempotency:** every mutating call must accept `idempotency_key` and be safe under retries.
* **Errors:** use a small, stable taxonomy (`InvalidInput`, `PreconditionFailed`, `NotFound`, `Conflict`, `QuotaExceeded`, `Transient`, `Internal`).

**TypeScript port signature (example):**

```ts
export interface BuildIndexParams {
  index_name: string;
  source_manifest_uri: string; // file:// s3:// etc.
  run_id: string;
  idempotency_key?: string;
  budget?: { seconds_max?: number; calls_max?: number };
}
export interface BuildIndexResult {
  manifest_uri: string;        // e.g. file://indexes/docs_main/manifest.json
  metrics: { docs: number; bytes: number; duration_ms: number };
}
```

### 3.2 Asynchronous artifacts (for big data and reproducibility)

**When:** exchanging large embeddings, indexes, corpora, evidence packs.

* **Rule:** APIs return **URIs** to artifacts; consumers read via filesystem/object store.
* **Layout (suggested):**

```text
/runs/<run_id>/inputs/*.jsonl
/runs/<run_id>/outputs/*.jsonl
/indexes/<name>/{manifest.json, *.index, meta.json}
/evidence/<topic>/<YYYYMMDD>/*.json
```

* **Manifest schema (minimal):**

```json
{
  "$schema": "https://schemas.ai-toolkit.dev/index-manifest-1.json",
  "name": "docs_main",
  "version": "1.2.0",
  "produced_by": "Index",
  "created_at": "2025-11-06T01:00:00Z",
  "run_id": "r_123",
  "contents": [
    {"path": "indexes/docs_main/faiss.index", "sha256": "..."},
    {"path": "indexes/docs_main/meta.json",  "sha256": "..."}
  ]
}
```

* **Content addressing:** include checksums (sha256) for every file; optional `size_bytes`, `content_type`.

### 3.3 Events (fan-out & decoupling)

**Bus:** start with **NATS** (preferred) or **Redis Streams**.
**Envelope:** **CloudEvents 1.0** JSON; at-least-once delivery; consumers are idempotent.

* **Topics (suggested):** `plan.created`, `agent.run.started`, `artifact.ready`, `index.updated`, `query.performed`, `eval.report.available`, `patch.pr.opened`.
* **DLQ:** per-consumer dead-letter subject/stream with alerting.
* **Ordering:** do not assume global ordering; use `run_id` scoping where order matters.

**CloudEvent example:**

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

---

## 4) Agent layer (policies on top of deterministic services)

* **Role:** agents apply judgment (planning, selection, trade-offs); services provide the capabilities.
* **Shape:** "agent shells" wrap steps that need reasoning; everything else is direct service calls.
* **Guardrails (agent sandwich):**

  * **Pre-validation:** schema + static checks ensure calls are safe before execution.
  * **Post-validation:** normalize/verify outputs; refuse to proceed on mismatches.
* **Budgets:** per-run ceilings (calls, tokens, seconds); enforced by Agent and respected by services.
* **Decision telemetry (no raw chain-of-thought):**

```json
{
  "run_id": "r_123",
  "goal": "refresh RAG index for docs_main",
  "capabilities_used": ["Search.web", "Ingest.load", "Index.build"],
  "decision_summary": "2 crawls stale; re-ingest 18 docs; rebuild IVF-Flat",
  "actions": [
    {"call": "Search.web", "args_ref": "runs/r_123/inputs/search.json"},
    {"call": "Ingest.load", "args_ref": "..."},
    {"call": "Index.build", "args_ref": "..."}
  ],
  "budget": {"calls_max": 30, "seconds_max": 300, "spent": {"calls": 7, "seconds": 92}}
}
```

* **Agent as an MCP client:** discovers providers, lists tools/resources, and invokes tools with run/budget/timebox controls; still emits structured `decision_summary` and tracing.

---

## 5) MCP integration (make services tool-ready for agents)

* **Adapter pattern:** add an **MCP Provider** beside each service; it forwards to the same internal port methods.
* **Transport:** `stdio` for local/dev; `wss` (with mTLS or signed tokens) for remote.
* **Protocol:** JSON-RPC message shapes defined by MCP; methods correspond to your service operations.
* **Tools:** 1:1 with service operations. Parameters/returns reuse your JSON Schemas.
* **Resources:** expose artifact **URIs** (e.g., `file://`, `s3://`) and implement `resources.read` with range support.
* **Capabilities handshake:** advertise `{version, tools, resources, limits}` for safe negotiation.
* **Concurrency & backpressure:** provider maintains per-tool concurrency; queue length caps + 429/`Retry-After` semantics.
* **Schema generation:** generate MCP tool schemas directly from the same JSON Schemas you use for internal types (single source of truth).
* **Idempotent handlers:** require `run_id` and/or `idempotency_key`; make handlers safe under retries/timeouts.

**MCP tool schema (example):**

```json
{
  "type": "object",
  "properties": {
    "index_name": {"type": "string"},
    "run_id": {"type": "string"},
    "budget": {
      "type": "object",
      "properties": {"seconds_max": {"type": "integer"}, "calls_max": {"type": "integer"}}
    },
    "idempotency_key": {"type": "string"}
  },
  "required": ["index_name", "run_id"]
}
```

---

## 6) Contracts, versioning, compatibility

* **Semver on operations:** breaking schema -> major; additive fields -> minor; metadata only -> patch.
* **Capability discovery:** each service exposes `/capabilities` or MCP `capabilities` with `{tool, versions, limits}`.
* **Deprecations:** support `x-deprecated: true` in schema + logs + metrics; remove only after two minors.
* **Consumer-driven contracts:** Pact tests for every tool/port pair; negative test cases included.

---

## 7) Observability & ops

* **Tracing:** OpenTelemetry; propagate `traceparent` through direct calls, events, and MCP.
* **Logging:** structured JSON with `{ts, level, service, tool, run_id, trace_id, caller, attempt, duration_ms}` (common picks: pino for TS, structlog for Python).
* **Metrics:** counters (`calls_total`, `errors_total`), histograms (`latency_ms`), gauges (`queue_depth`).
* **SLOs:** set p95 latency and availability per tool; burn-rate alerts (multi-window) wired to on-call.
* **Replayability:** keep artifacts + manifests to reproduce runs; ensure index builds are deterministic given inputs + config.

---

## 8) Security & compliance

* **AuthN/Z:**

  * Internal calls: mTLS between services or Unix domain sockets.
  * MCP over `wss`: mTLS or signed JWT with audience = service; short TTL; rotate keys.
  * Per-tool RBAC/allowlist; default deny.
* **Secret handling:** via Vault (or OS keyring) injected at runtime; never in manifests.
* **Egress control:** allowlist destinations; SSRF-harden fetchers; forbid file-scheme escapes.
* **Supply chain & gates:** SBOM, license policy, static scanning (CodeQL/Semgrep), and contract tests (including MCP adapters) in CI.

---

## 9) Reliability patterns

* **Retries:** exponential backoff with jitter; classify retryable vs. terminal errors.
* **Idempotency:** dedupe table keyed by `idempotency_key`; return prior result on repeat.
* **DLQ:** event consumers push poison messages to DLQ with reason; alert and surface in Observe.
* **Graceful shutdown:** drain queues; stop admitting work; flush traces/logs.
* **Rollbacks:** guard MCP exposure behind feature flags; disable the provider or individual tools quickly if SLOs burn.
* **Server-side budgets:** enforce deadlines and budgets in providers (reject early on exhausted budgets).

---

## 10) Rollout playbooks

### 10.1 Add a new service operation

1. Write/extend JSON Schema (+ examples).
2. Generate types (TS/Py) and port interface.
3. Implement core logic (deterministic).
4. Add contract tests (consumer/provider) + golden files.
5. Add metrics + tracing + error taxonomy coverage.
6. Document operation (inputs/outputs, limits).
7. If needed, expose via MCP provider (tool + resource mapping).

### 10.2 Expose a service via MCP

1. Create provider adapter; map tools 1:1.
2. Implement `capabilities` and `resources.read` (range).
3. Add auth (mTLS/JWT), concurrency caps, and timeouts.
4. Contract tests: direct port vs. MCP call parity.
5. Soak in staging with burn-rate SLO alerts.

### 10.3 Agentize a step

1. Define success criteria & limits (budget/timebox).
2. Add pre/post validators (agent sandwich).
3. Emit `decision_summary` and action list.
4. Run A/B against deterministic baseline; keep if ROI is clear.

---

## 11) Reference snippets

**NATS docker-compose (minimal):**

```yaml
services:
  nats:
    image: nats:2
    command: ["-js", "-sd", "/data"]
    ports: ["4222:4222", "8222:8222"]
    volumes: ["./data:/data"]
```

**Redis Streams alternative (consumer group):**

```bash
# Producer
gxadd toolkit.index.updated * run_id r_123 manifest_uri file://... index_name docs_main
# Consumer (group "workers")
gxgroup create toolkit.index.updated workers $ MKSTREAM
xreadgroup group workers a1 count 1 block 2000 streams toolkit.index.updated >
```

**Direct HTTP fallback (optional):**

```http
POST /v1/indexes/build
Content-Type: application/json
{
  "index_name": "docs_main",
  "source_manifest_uri": "s3://bucket/docs_main/manifest.json",
  "run_id": "r_123"
}
```

**Error envelope (uniform):**

```json
{
  "error": {
    "code": "PreconditionFailed",
    "message": "Source manifest missing faiss index",
    "details": {"missing": ["faiss.index"]},
    "trace_id": "..."
  }
}
```

---

## 12) FAQ

* **Do we need gRPC?** Only if you require streaming/binary perf across a network boundary. Otherwise keep direct calls + artifacts.
* **When to use events vs. direct calls?** Events for fan-out/decoupling; direct calls for request/response workflows.
* **How to change a schema safely?** Additive first; announce deprecation; support both shapes for two minor versions; track usage via logs/metrics.
* **Where do big files go?** Never in RPC; always in object store/disk, referenced by URI + manifest.
* **How do agents collaborate?** Through the **Agent** service, which sequences deterministic service calls and wraps judgment steps in small agent shells; MCP is an adapter, not a replacement.

---

## 13) Quality bar checklist (ship-ready)

* [ ] JSON Schema written with examples and constraints.
* [ ] Types generated (TS/Py); ports updated.
* [ ] Idempotency enforced; retries tested.
* [ ] Tracing/logging/metrics added; dashboards updated.
* [ ] SLOs defined; burn-rate alerts configured.
* [ ] Pact tests pass (direct vs. MCP); negative cases included.
* [ ] Security reviewed (authZ, SSRF, egress, secrets).
* [ ] Artifacts & manifests reproducible; checksums recorded.
* [ ] Docs updated here; examples runnable.

---

**Bottom line:** Keep core service-to-service comms boring (typed calls + artifacts + events). Use the Agent service for judgment where it clearly pays off. Add MCP providers as a facade when agents (yours or external) need to call services as tools—all without bending Harmony's simplicity-first guardrails.

---

## Appendix — Library picks (open-source, self-hostable)

* MCP SDKs: official TypeScript and Python SDKs.
* Events: NATS (preferred) or Redis Streams using CloudEvents JSON.
* Typing/validation: typebox/zod + AJV (TS), pydantic v2 (Py).
* Tracing/logging: OpenTelemetry exporters + pino (TS) / structlog (Py).
* Optional RPC/HTTP: FastAPI (Py) or tiny OpenAPI client; gRPC when streaming/binary is required.
