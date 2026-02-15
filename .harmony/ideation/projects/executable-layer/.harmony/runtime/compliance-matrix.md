# Compliance matrix (spec-bundle.md)

> This maps **normative MUST requirements** from `spec-bundle.md` to the concrete implementation locations.

| # | Requirement (from spec-bundle.md) | Location | Status |
|---|-----------------------------------|----------|--------|
| 1 | `service.json.format_version` MUST equal `service-manifest-v1` (§1.2) | `.harmony/runtime/crates/core/src/discovery.rs:L54-L60` | Done |
| 2 | Kernel MUST validate `service.json` against JSON Schema (§1.2) | `.harmony/runtime/crates/core/src/schema.rs:SchemaStore::validate_service_manifest` | Done |
| 3 | Kernel MUST require `entry` wasm file exists before allowing service load (§1.2) | `.harmony/runtime/crates/core/src/discovery.rs:L72-L76` | Done |
| 4 | If `integrity.wasm_sha256` is present, kernel MUST verify it at load time (§1.2) | `.harmony/runtime/crates/core/src/discovery.rs:L78-L98` | Done |
| 5 | Input MUST be validated against `input_schema` before invoking (§1.2) | `.harmony/runtime/crates/wasm_host/src/invoke.rs:L53-L61` | Done |
| 6 | Output MUST be validated against `output_schema` after invoking (§1.2) | `.harmony/runtime/crates/wasm_host/src/invoke.rs:L165-L180` | Done |
| 7 | Kernel MUST enforce `max_request_bytes` (§1.2) | `.harmony/runtime/crates/wasm_host/src/invoke.rs:L64-L83` | Done |
| 8 | Kernel MUST enforce `max_response_bytes` (§1.2) | `.harmony/runtime/crates/wasm_host/src/invoke.rs:L150-L162` | Done |
| 9 | Kernel MUST enforce `timeout_ms` (§1.2) | `.harmony/runtime/crates/wasm_host/src/host.rs:L30-L40` (epoch ticker) + `.harmony/runtime/crates/wasm_host/src/run_component.rs:L33-L40` (epoch deadline) | Done (best-effort) |
| 10 | Kernel MUST enforce `max_concurrency` (§1.2) | `.harmony/runtime/crates/core/src/limits.rs:ConcurrencyManager::try_acquire` + `.harmony/runtime/crates/wasm_host/src/invoke.rs:L85-L90` | Done |
| 11 | Kernel MUST deny-by-default; service gets no capabilities unless granted (§5 + §7) | `.harmony/runtime/crates/core/src/policy.rs:L21-L73` | Done |
| 12 | Host APIs MUST check `GrantSet` on every call (§5, §7) | `.harmony/runtime/crates/wasm_host/src/host_api.rs` (each method begins with `self.grants.require(...)`) | Done |
| 13 | Capability id `log.write` MUST be enforced (§7) | `.harmony/runtime/crates/wasm_host/src/host_api.rs:L5-L11` | Done |
| 14 | Capability id `clock.read` MUST be enforced (§7) | `.harmony/runtime/crates/wasm_host/src/host_api.rs:L14-L22` | Done |
| 15 | Capability id `storage.local` MUST be enforced (§7) | `.harmony/runtime/crates/wasm_host/src/host_api.rs:L24-L41` | Done |
| 16 | Capability id `fs.read` MUST be enforced (§7) | `.harmony/runtime/crates/wasm_host/src/host_api.rs:L43-L71` | Done |
| 17 | Capability id `fs.write` MUST be enforced (§7) | `.harmony/runtime/crates/wasm_host/src/host_api.rs:L73-L118` | Done |
| 18 | NDJSON protocol: kernel MUST accept `hello` and respond with `hello` (§4) | `.harmony/runtime/crates/kernel/src/stdio.rs:L20-L63` | Done |
| 19 | NDJSON protocol: wrong/unknown protocol MUST return `PROTOCOL_UNSUPPORTED` (§4) | `.harmony/runtime/crates/kernel/src/stdio.rs:L40-L49` | Done |
| 20 | NDJSON protocol: messages MUST be one JSON object per line (§4) | `.harmony/runtime/crates/core/src/jsonlines.rs` | Done |
| 21 | NDJSON protocol: kernel MUST support request `tool.invoke` (§4) | `.harmony/runtime/crates/kernel/src/stdio.rs:L115-L230` | Done |
| 22 | NDJSON protocol: unknown method MUST return `UNKNOWN_METHOD` (§4) | `.harmony/runtime/crates/kernel/src/stdio.rs:L263-L273` | Done |
| 23 | NDJSON protocol: kernel MUST support `cancel` and best-effort cancellation (§4) | `.harmony/runtime/crates/kernel/src/stdio.rs:L232-L262` + `.harmony/runtime/crates/wasm_host/src/run_component.rs:L30-L37` + `.harmony/runtime/crates/wasm_host/src/cancel.rs` | Done (best-effort) |
| 24 | Error object MUST include `code` + `message` (+ optional `details`) (§4) | `.harmony/runtime/crates/core/src/errors.rs:KernelError::as_error_object` | Done |
| 25 | Error codes MUST use the v1 set (§4) | `.harmony/runtime/crates/core/src/errors.rs:ErrorCode::as_str` | Done |
| 26 | RootResolver MUST locate `.harmony/` from cwd or parents (§5) | `.harmony/runtime/crates/core/src/root.rs:RootResolver::resolve` | Done |
| 27 | Canonical WIT world MUST match reference (§5) | `.harmony/runtime/wit/world.wit` | Done |
| 28 | Kernel CLI commands MUST exist: `info`, `services list`, `tool`, `validate`, `serve-stdio`, `service new`, `service build` (impl architecture checklist) | `.harmony/runtime/crates/kernel/src/main.rs` + `.harmony/runtime/crates/kernel/src/scaffold.rs` + `.harmony/runtime/crates/kernel/src/stdio.rs` | Done |
| 29 | ScopedFs security: reject `..` traversal (§Security checklist) | `.harmony/runtime/crates/wasm_host/src/scoped_fs.rs:L212-L257` (`sanitize_relative`) | Done |
| 30 | ScopedFs security: prevent symlink escape (§Security checklist) | `.harmony/runtime/crates/wasm_host/src/scoped_fs.rs:L278-L296` (`ensure_no_symlink_components_existing`) + checks in read/write paths | Done |
| 31 | ScopedFs security: writes MUST be atomic (§Security checklist) | `.harmony/runtime/crates/wasm_host/src/scoped_fs.rs:L366-L392` (`atomic_write_file`) | Done |
| 32 | ScopedFs security: `fs.read` and `fs.write` separated (§Security checklist) | `.harmony/runtime/crates/wasm_host/src/host_api.rs:L43-L83` | Done |

