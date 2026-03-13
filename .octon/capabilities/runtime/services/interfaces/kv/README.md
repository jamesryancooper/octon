# KV Service

Local key/value storage service for Octon runtime state. This interface
service is implemented as a WASM component and registered as `interfaces/kv`.

## Purpose

- Persist durable runtime state under `.octon/engine/_ops/state/kv/`.
- Expose simple JSON ops through `invoke(op, input-json)`.
- Keep state operations deterministic and idempotent.

## Contract and Artifacts

- `service.json` - executable service manifest (ops, limits, required capabilities, entrypoint).
- `service.wasm` - compiled service binary loaded by the runtime.
- `rust/src/lib.rs` - op dispatcher implementation (`put`, `get`, `del`).
- `rust/wit/world.wit` - `octon:runtime@1.0.0` world contract used by generated bindings.
- `.octon/capabilities/runtime/services/manifest.runtime.yml` - Tier 1 discovery (`interfaces/kv`).
- `.octon/capabilities/runtime/services/registry.runtime.yml` - Tier 2 metadata (owner, risk, state path).

## Operations

| Op | Input JSON | Output JSON | Notes |
|---|---|---|---|
| `put` | `{"key":"<string>","value":"<string>"}` | `{"ok":true}` | Idempotent overwrite; emits an info log event. |
| `get` | `{"key":"<string>"}` | `{"value":"<string|null>"}` | Returns `null` when key is missing. |
| `del` | `{"key":"<string>"}` | `{"ok":true}` | Idempotent delete. |

All op input/output schemas are defined in `service.json`.

## Runtime Requirements

- Required capabilities: `storage.local`, `log.write`.
- State directory: `.octon/engine/_ops/state/kv`.
- Manifest limits:
  - `max_concurrency`: 4
  - `timeout_ms`: 30000
  - `max_request_bytes`: 1048576
  - `max_response_bytes`: 1048576

## Data Model

- Keys are case-sensitive strings.
- Values are UTF-8 strings in v1.
- Host persistence is a JSON map at `.octon/engine/_ops/state/kv/store.json`.

## Development

From `.octon/capabilities/runtime/services/interfaces/kv/rust/`:

```bash
cargo component check
cargo component build --release
```

Build output currently lands at:

```text
target/wasm32-wasip1/release/octon_kv_service.wasm
```

When replacing `service.wasm`, update `service.json.integrity.wasm_sha256`.
