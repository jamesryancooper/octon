# Spec Bundle (Authoritative v1 Contracts)

> **This document is the single source of truth for all v1 normative contracts.** Other documents in this bundle (implementation architecture, Rust examples) reference these contracts but do not redefine them. If there is a conflict, this document wins.

The v1 contracts cover:

1. `service.json` (runtime service manifest) + JSON Schema
2. `capabilities/services/manifest.yml` (Tier 1 discovery)
3. `capabilities/services/registry.yml` (Tier 2 metadata)
4. NDJSON stdio protocol (session mode) + versioning rules
5. Kernel module architecture (conceptual, language-agnostic)
6. Capability identifiers (v1 baseline)

These files are intended to live under `.harmony/spec/` (or wherever you prefer).

> **See also:**
>
> - [executable-layer-implementation-architecture.md](executable-layer-implementation-architecture.md) — repo layout, portability rules, cross-OS bootstrap, caching, CLI surface, implementation checklist
> - [rust-kernel-reference.md](rust-kernel-reference.md) — Rust host-side implementation (workspace, WIT, core types, Wasmtime integration)
> - [rust-fs-host-api.md](rust-fs-host-api.md) — sandboxed filesystem host API (Rust)
> - [rust-service-authoring.md](rust-service-authoring.md) — guest-side service authoring (Rust + cargo-component)

---

# 1) Runtime Service Manifest: `service.json` (v1)

## 1.1 File location

```
.harmony/capabilities/services/<category>/<service>/
  service.json
  service.wasm
```

## 1.2 `service.json` format (normative)

```json
{
  "format_version": "service-manifest-v1",
  "name": "kv",
  "version": "1.0.0",
  "category": "agent-platform",
  "abi": "wasi-component@0.2",
  "entry": "service.wasm",

  "capabilities_required": [
    "storage.local",
    "log.write"
  ],

  "ops": {
    "get": {
      "input_schema": {
        "type": "object",
        "properties": { "key": { "type": "string", "minLength": 1 } },
        "required": ["key"],
        "additionalProperties": false
      },
      "output_schema": {
        "type": "object",
        "properties": { "value": { "type": ["string", "null"] } },
        "required": ["value"],
        "additionalProperties": false
      },
      "idempotent": true,
      "streaming": false
    },
    "put": {
      "input_schema": {
        "type": "object",
        "properties": {
          "key": { "type": "string", "minLength": 1 },
          "value": { "type": "string" }
        },
        "required": ["key", "value"],
        "additionalProperties": false
      },
      "output_schema": {
        "type": "object",
        "properties": { "ok": { "type": "boolean" } },
        "required": ["ok"],
        "additionalProperties": false
      },
      "idempotent": true,
      "streaming": false
    }
  },

  "limits": {
    "max_request_bytes": 1048576,
    "max_response_bytes": 1048576,
    "timeout_ms": 30000,
    "max_concurrency": 4
  },

  "integrity": {
    "wasm_sha256": "<optional-hex-sha256>"
  },

  "docs": {
    "summary": "Local key/value storage for Harmony runtime state.",
    "help": "Use for durable state under .harmony/state/kv/. Keys are strings; values are UTF-8 strings in v1."
  }
}
```

### Required behaviors (kernel MUST enforce)

* `format_version` must match exactly.
* `entry` must exist and be inside the same service folder.
* Input payloads MUST be validated against `input_schema` before invoking.
* Outputs MUST be validated against `output_schema` before returning (fail closed).
* Kernel MUST enforce `limits.*` (timeouts, size caps, concurrency).
* Kernel MUST enforce `capabilities_required` via policy (deny by default).
* If `integrity.wasm_sha256` exists, kernel MUST verify before loading.

---

## 1.3 JSON Schema for `service.json`

Create `.harmony/spec/service-manifest-v1.schema.json`:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://harmony.local/spec/service-manifest-v1.schema.json",
  "title": "Harmony Service Manifest v1",
  "type": "object",
  "required": [
    "format_version",
    "name",
    "version",
    "category",
    "abi",
    "entry",
    "capabilities_required",
    "ops",
    "limits"
  ],
  "additionalProperties": false,
  "properties": {
    "format_version": {
      "const": "service-manifest-v1"
    },
    "name": {
      "type": "string",
      "pattern": "^[a-z][a-z0-9_-]{0,63}$"
    },
    "version": {
      "type": "string",
      "pattern": "^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-[0-9A-Za-z.-]+)?(?:\\+[0-9A-Za-z.-]+)?$"
    },
    "category": {
      "type": "string",
      "pattern": "^[a-z][a-z0-9_-]{0,63}$"
    },
    "abi": {
      "type": "string",
      "minLength": 1
    },
    "entry": {
      "type": "string",
      "pattern": "^[^\\\\/:*?\"<>|]+\\.wasm$"
    },
    "capabilities_required": {
      "type": "array",
      "items": { "type": "string", "minLength": 1 },
      "uniqueItems": true
    },
    "ops": {
      "type": "object",
      "minProperties": 1,
      "additionalProperties": {
        "type": "object",
        "required": ["input_schema", "output_schema"],
        "additionalProperties": false,
        "properties": {
          "input_schema": { "type": "object" },
          "output_schema": { "type": "object" },
          "idempotent": { "type": "boolean", "default": false },
          "streaming": { "type": "boolean", "default": false }
        }
      }
    },
    "limits": {
      "type": "object",
      "required": [
        "max_request_bytes",
        "max_response_bytes",
        "timeout_ms",
        "max_concurrency"
      ],
      "additionalProperties": false,
      "properties": {
        "max_request_bytes": { "type": "integer", "minimum": 1024, "maximum": 33554432 },
        "max_response_bytes": { "type": "integer", "minimum": 1024, "maximum": 33554432 },
        "timeout_ms": { "type": "integer", "minimum": 1, "maximum": 600000 },
        "max_concurrency": { "type": "integer", "minimum": 1, "maximum": 256 }
      }
    },
    "integrity": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "wasm_sha256": {
          "type": "string",
          "pattern": "^[a-fA-F0-9]{64}$"
        }
      }
    },
    "docs": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "summary": { "type": "string" },
        "help": { "type": "string" }
      }
    }
  }
}
```

---

# 2) Tier 1 discovery: `capabilities/services/manifest.yml` (v1)

Purpose: **low-token routing index**. Agents can scan this quickly.

Create `.harmony/capabilities/services/manifest.yml`:

```yaml
format_version: services-manifest-v1
services:
  - id: agent-platform/kv
    name: kv
    category: agent-platform
    summary: Local key/value storage.
    triggers:
      - "state"
      - "memory"
      - "kv"
    runtime:
      type: wasm
      path: agent-platform/kv/service.json

  - id: agent-platform/policy
    name: policy
    category: agent-platform
    summary: Capability decisions and explanations.
    triggers:
      - "policy"
      - "permissions"
      - "allowlist"
    runtime:
      type: wasm
      path: agent-platform/policy/service.json
```

Rules:

* `id` is stable and unique across the harness.
* `runtime.path` points to `service.json` relative to `capabilities/services/`.
* Keep `summary` short; keep `triggers` small.

---

# 3) Tier 2 metadata: `capabilities/services/registry.yml` (v1)

Purpose: **richer metadata** used after a match: risk tier, approvals, dependencies, I/O locations, examples, etc.

Create `.harmony/capabilities/services/registry.yml`:

```yaml
format_version: services-registry-v1
services:
  agent-platform/kv:
    owner: agency/platform
    risk_tier: low
    approvals:
      invoke: none
      writes: human_if_outside_scope
    depends_on: []
    io:
      state_dir: .harmony/state/kv
    notes:
      - "Values are UTF-8 strings in v1."
      - "Keys are case-sensitive."
    observability:
      log_events: true
      trace_inputs: redacted
      trace_outputs: redacted

  agent-platform/policy:
    owner: agency/platform
    risk_tier: low
    approvals:
      invoke: none
    depends_on: []
    notes:
      - "Provides policy evaluation and explanation."
```

Rules:

* Keys are service IDs (same as Tier 1 `id`).
* Kernel does not need this file to run services, but it’s useful for governance/agents.

---

# 4) NDJSON stdio protocol spec (v1)

Create `.harmony/spec/stdio-protocol-v1.md` with these normative rules:

## 4.1 Transport

* UTF-8 text
* One JSON object per line (`\n` or `\r\n`)
* Max line length: kernel-configurable (default 1 MiB)

## 4.2 Version negotiation

First message from client MUST be:

```json
{"type":"hello","protocol":"harmony-stdio-v1","client":{"name":"<string>","version":"<string>"}}
```

Kernel responds:

```json
{"type":"hello","protocol":"harmony-stdio-v1","kernel":{"version":"<string>","os":"<string>","arch":"<string>"}}
```

If protocol mismatch, kernel responds with:

```json
{"type":"error","error":{"code":"PROTOCOL_UNSUPPORTED","message":"..."}}
```

## 4.3 Message shapes

All subsequent messages MUST include `id` for request/response/event correlation.

### Request

```json
{
  "id": "1",
  "type": "request",
  "method": "tool.invoke",
  "params": {
    "service": "kv",
    "category": "agent-platform",
    "op": "get",
    "input": { "key": "x" }
  },
  "meta": {
    "trace_id": "optional",
    "deadline_ms": 30000
  }
}
```

### Response

```json
{
  "id": "1",
  "type": "response",
  "ok": true,
  "result": { "value": "..." }
}
```

### Error response

```json
{
  "id": "1",
  "type": "response",
  "ok": false,
  "error": {
    "code": "CAPABILITY_DENIED",
    "message": "storage.local not granted",
    "details": { "capability": "storage.local" }
  }
}
```

### Events (streaming ops only)

```json
{"id":"9","type":"event","event":"chunk","data":{...}}
{"id":"9","type":"event","event":"done"}
```

## 4.4 Cancellation

Client may cancel an in-flight request:

```json
{"type":"request","id":"cancel-1","method":"cancel","params":{"id":"9"}}
```

Kernel MUST best-effort cancel and then emit:

* a final response for `id:"9"` with `ok:false` and `code:"CANCELLED"` (or `ok:true` if already finished).

## 4.5 Standard error codes (v1)

* `PROTOCOL_UNSUPPORTED`
* `MALFORMED_JSON`
* `REQUEST_TOO_LARGE`
* `UNKNOWN_METHOD`
* `UNKNOWN_SERVICE`
* `UNKNOWN_OPERATION`
* `INVALID_INPUT`
* `CAPABILITY_DENIED`
* `TIMEOUT`
* `SERVICE_TRAP`
* `INTERNAL`
* `CANCELLED`

---

# 5) Kernel module architecture (conceptual)

This section defines the **logical modules** and their responsibilities. It is language-agnostic — the concepts apply regardless of implementation language. For a concrete Rust implementation, see [rust-kernel-reference.md](rust-kernel-reference.md).

## 5.1 Top-level modules

1. **RootResolver**

   * Input: current working directory
   * Output: path to active `.harmony/` (nearest ancestor)
   * Rules: walk upward until found; error if none

2. **ConfigLoader**

   * Reads `.harmony/harmony.yml` + optional runtime config file(s)
   * Produces: `RuntimeConfig` (paths, policy, defaults)

3. **ServiceDiscovery**

   * Scans `.harmony/capabilities/services/**/service.json`
   * Validates each against `service-manifest-v1.schema.json`
   * Builds `ServiceRegistry`:

     ```text
     ServiceKey { category, name } -> ServiceDescriptor { version, dir, wasm_path, manifest }
     ```

4. **PolicyEngine**

   * Inputs: caller context (agent/skill/tool), service manifest, config rules
   * Output: `GrantSet` (capabilities granted) OR denial with explanation
   * Rules:

     * deny-by-default
     * allow only capabilities explicitly permitted by policy
     * apply path scope rules (workspace root)

5. **WasmHost**

   * Wraps Wasmtime
   * Responsibilities:

     * cache compiled artifacts (use `.harmony/state/wasmtime-cache/`)
     * instantiate component with WASI + host imports
     * enforce timeouts / memory limits / fuel (if you choose)
     * map traps to `SERVICE_TRAP`

6. **HostAPIs**

   * The only place that touches OS resources
   * APIs (v1 recommended):

     * `log.write(level, msg)`
     * `clock.now_ms()`
     * `storage.get/put/delete/list(prefix)`
     * `fs.read/fs.write/fs.list/fs.glob` (scoped)
   * Each API checks `GrantSet` before executing

7. **Invoker**

   * `invoke(service, op, input)`:

     * validate input against `input_schema`
     * call Wasm export
     * validate output against `output_schema`
     * enforce `max_response_bytes`
   * Handles streaming ops via events

8. **TraceWriter**

   * Appends NDJSON events to `.harmony/state/traces/<trace_id>.ndjson`
   * Events to record:

     * request received
     * policy decision
     * invocation started/ended
     * errors/timeouts
   * Supports redaction rules

9. **CLI**

   * `info`, `services list`, `tool`, `run`, `validate`, `serve-stdio`
   * For `serve-stdio`: runs a loop:

     * read line → parse JSON
     * dispatch to Invoker
     * write response/event lines

## 5.2 Data flow for `tool.invoke`

1. CLI/stdio receives request
2. RootResolver selects `.harmony/`
3. ServiceDiscovery resolves service descriptor
4. PolicyEngine computes grants
5. Invoker validates input and calls WasmHost
6. HostAPIs mediate all privileged calls
7. Invoker validates output, returns response
8. TraceWriter logs lifecycle

---

# 6) Concrete “spec bundle” file list to add

```text
.harmony/spec/
  service-manifest-v1.schema.json
  stdio-protocol-v1.md
  policy-v1.md                 # (optional) capability strings + defaults
  errors-v1.md                 # (optional) canonical error codes/messages
```

---

# 7) Optional: a minimal `policy-v1.md` (capability strings)

If you want a single source of truth for capability identifiers, add:

```text
Capabilities (v1)
- log.write
- clock.read
- storage.local
- fs.read
- fs.write
- env.read
- process.exec
- net.connect
```

Then your runtime config can map service IDs → allowed capabilities.
