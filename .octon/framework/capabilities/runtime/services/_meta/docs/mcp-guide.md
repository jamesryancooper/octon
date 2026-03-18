# MCP Provider Guide — Tool/Resource Mapping, Security, Compatibility

**Octon-aligned.** MCP is an adapter on your hexagonal boundary. It exposes existing service operations as **tools** and large data as **resources** for agents (local or remote) without changing your core comms stack.

---

## 1) Provider architecture

* **Adapter, not rewrite:** Keep service ports intact. Provider calls the same internal methods.
* **Transports:**

  * **Local:** `stdio` (no network, simplest for dev/tests).
  * **Remote:** `wss` with mTLS/JWT, behind ingress with egress controls.
* **Protocol:** JSON-RPC as defined by MCP; 1:1 mapping to service ops.

---

## 2) Tool mapping (contracts first)

* **Schema reuse:** Tool params/returns reuse the service's JSON Schemas.
* **Naming:** `service.operation` (e.g., `index.build`, `ingest.load`).
* **Metadata:** expose `{version, limits, costs}` in a `capabilities` handshake.

**Example tool schema (build index):**

```json
{
  "type": "object",
  "properties": {
    "index_name": {"type": "string"},
    "source_manifest_uri": {"type": "string"},
    "run_id": {"type": "string"},
    "budget": {
      "type": "object",
      "properties": {"seconds_max": {"type": "integer"}, "calls_max": {"type": "integer"}}
    },
    "idempotency_key": {"type": "string"}
  },
  "required": ["index_name", "source_manifest_uri", "run_id"]
}
```

---

## 3) Resources (large data via URIs)

* **Rule:** tools return **URIs**, not large payloads.
* **Supported schemes:** `file://`, `s3://` (others via adapter). Avoid arbitrary `http(s)://` unless allowlisted.
* **Range reads:** implement `resources.read` with byte-range support for large files.
* **Manifests:** a resource may point to a manifest that lists multiple files with checksums.

---

## 4) Security

* **AuthN:**

  * Local stdio → no network exposure (dev only).
  * Remote `wss` → **mTLS** or **JWT** (short TTL, `aud` = service name, issuer pinned).
* **AuthZ:** per-tool allowlist/denylist (RBAC), default deny.
* **Isolation:** resource path sandboxing; block `..`/symlink escapes; no arbitrary shelling out.
* **Egress controls:** DNS and IP allowlist; SSRF-harden any fetchers.
* **Secrets:** load from Vault/OS keyring at start; never return secrets via tools.

---

## 5) Limits, backpressure, and QoS

* **Concurrency caps:** per-tool worker pool; queue length bounds; shed load with 429-equivalent.
* **Deadlines:** respect client `deadline_ms`; cancel work promptly.
* **Budgets:** enforce `{seconds_max, calls_max}` server-side; surface remaining budget in responses when helpful.
* **Large responses:** prefer manifest URIs; chunked reads; optional compression (zstd) on resources.

---

## 6) Compatibility & versioning

* **Semver:** breaking schema → major; additive → minor.
* **Capabilities handshake:** advertise supported versions `{tool, versions}`; refuse unsupported shapes with `InvalidInput`.
* **Deprecation policy:** mark tool versions as deprecated; log usage; remove after 2 minors with <5% traffic.
* **Cross-matrix:** maintain `Agent vX ↔ Provider vY` compatibility matrix in docs.

---

## 7) Testing & CI

* **Parity tests:** same fixtures through **direct port** and **MCP tool** must yield identical results (allowing non-semantic diffs like timestamps).
* **Negative tests:** invalid params, permission denied, oversized payloads, deadline exceeded.
* **Fuzzing:** schema-aware fuzz on params; ensure provider rejects out-of-contract fields.
* **Smoke tests:** provider liveness, `capabilities` shape, resource range-reads.

---

## 8) Observability

* **Tracing:** propagate `traceparent` in MCP metadata; span per tool call.
* **Logging:** structured logs `{service, tool, caller, run_id, trace_id, duration_ms, attempt, outcome}`.
* **Metrics:** per-tool `requests_total`, `errors_total{code=…}`, `duration_ms`, `queue_depth`.

---

## 9) Deployment

* **Local:** start provider alongside the service (stdio); Agent connects directly.
* **Staging/Prod:** deploy behind ingress; terminate TLS; enforce client certs or JWT.
* **Rollouts:** canary by routing % of Agent traffic to new provider version; monitor SLOs & error budget burn.

---

## 10) Example responses

**Success:**

```json
{
  "manifest_uri": "file://indexes/docs_main/manifest.json",
  "metrics": {"docs": 1200, "bytes": 73400320, "duration_ms": 58231}
}
```

**Failure:**

```json
{
  "error": {"code": "QuotaExceeded", "message": "Too many concurrent builds", "trace_id": "..."}
}
```
