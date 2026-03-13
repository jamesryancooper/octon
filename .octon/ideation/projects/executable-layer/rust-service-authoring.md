# Rust Service Authoring Guide

This document covers **guest-side service development**: how to author, build, and deploy Octon services as WebAssembly components using Rust and `cargo-component`.

> **Scope:** Guest-side (service authoring) only. For the kernel host-side implementation (HostState, host APIs, linker wiring, KvStore, GrantSet), see [rust-kernel-reference.md](rust-kernel-reference.md). For the canonical WIT contract, see [rust-kernel-reference.md §3](rust-kernel-reference.md). For normative contracts, see [spec-bundle.md](spec-bundle.md).

---

## 1) Toolchain

### Recommended build tool: `cargo-component`

This is the cleanest "Rust to component" path today. It builds a core Wasm module and adapts it into a WASI Preview2 ("WASIp2") component, handling adapter details for you. ([GitHub][1])

**Install**

```bash
cargo install cargo-component
```

### Target

`cargo-component` uses the `wasm32-wasip1` target and adapts to WASIp2 components automatically. You get consistent artifacts: `service.wasm` that the kernel can load as a component. ([GitHub][1])

---

## 2) Service ABI (v1): `invoke(op, input_json) -> output_json`

Even though the component model supports rich typed interfaces, Octon already has typed I/O at the harness level via `service.json` JSON Schemas. For v1, keep the component ABI stable and generic:

- Exported function: `invoke(op: string, input_json: string) -> string`

Benefits:

- No need to regenerate host bindings per-service op set
- Adding ops is a `service.json` + service code update only
- The kernel remains the schema enforcer
- You can introduce fully typed per-op exports later without breaking v1

The WIT world defining this ABI is in [rust-kernel-reference.md §3](rust-kernel-reference.md).

---

## 3) Service folder structure

Each service is a self-contained folder:

```text
.octon/capabilities/services/<category>/<service>/
  service.json           # runtime manifest (format: spec-bundle.md §1)
  service.wasm           # build output
  rust/
    Cargo.toml
    src/lib.rs
    wit/
      world.wit          # copy of the canonical WIT from .octon/runtime/wit/
```

---

## 4) Service template files

### 4.1 `service.json` (scaffold)

Format defined in [spec-bundle.md §1](spec-bundle.md). Scaffold version:

```json
{
  "format_version": "service-manifest-v1",
  "name": "<name>",
  "version": "0.1.0",
  "category": "<category>",
  "abi": "wasi-component@0.2",
  "entry": "service.wasm",
  "capabilities_required": ["log.write"],
  "ops": {
    "ping": {
      "input_schema": {
        "type": "object",
        "properties": {},
        "required": [],
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
  "integrity": {},
  "docs": {
    "summary": "<summary>",
    "help": "Service scaffold. Implement ops in rust/src/lib.rs and update schemas here."
  }
}
```

### 4.2 `rust/Cargo.toml`

```toml
[package]
name = "octon-service-<category>-<name>"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib"]

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
wit-bindgen = "0.26"
wit-bindgen-rt = "0.26"

[package.metadata.component]
package = "octon:runtime"
world = "octon-service"
```

`cargo-component` reads `[package.metadata.component]` to build a WebAssembly component. ([GitHub][1])

### 4.3 `rust/wit/world.wit`

This should be identical to the canonical WIT at `.octon/runtime/wit/world.wit` (defined in [rust-kernel-reference.md §3](rust-kernel-reference.md)). The `service new` command copies it at scaffold time.

### 4.4 `rust/src/lib.rs` (scaffold)

Uses the official `wit_bindgen::generate!` + `export!` pattern for Rust guest components. ([component-model.bytecodealliance.org][2])

```rust
mod bindings {
    wit_bindgen::generate!({
        path: "wit/world.wit",
        world: "octon-service",
    });

    use super::Service;
    export!(Service);
}

use serde_json::{json, Value};

struct Service;

impl bindings::Guest for Service {
    fn invoke(op: String, input_json: String) -> String {
        let _input: Value = match serde_json::from_str(&input_json) {
            Ok(v) => v,
            Err(_) => return err("MALFORMED_JSON", "input_json is not valid JSON"),
        };

        match op.as_str() {
            "ping" => ok(json!({"ok": true})),
            _ => err("UNKNOWN_OPERATION", "unknown op"),
        }
    }
}

fn ok(result: Value) -> String {
    json!({"ok": true, "result": result}).to_string()
}

fn err(code: &str, message: &str) -> String {
    json!({"ok": false, "error": {"code": code, "message": message}}).to_string()
}
```

---

## 5) KV service reference implementation

A complete guest-side implementation showing how to call host imports (`kv.*`):

`rust/src/lib.rs`:

```rust
mod bindings {
    wit_bindgen::generate!({
        path: "wit/world.wit",
        world: "octon-service",
    });

    use super::KvService;
    export!(KvService);
}

use serde_json::{json, Value};

struct KvService;

impl bindings::Guest for KvService {
    fn invoke(op: String, input_json: String) -> String {
        let input: Value = match serde_json::from_str(&input_json) {
            Ok(v) => v,
            Err(_) => return err("MALFORMED_JSON", "input_json is not valid JSON"),
        };

        match op.as_str() {
            "get" => {
                let key = match input.get("key").and_then(|v| v.as_str()) {
                    Some(k) if !k.is_empty() => k,
                    _ => return err("INVALID_INPUT", "missing 'key'"),
                };

                let value = bindings::kv::get(key);
                ok(json!({ "value": value }))
            }

            "put" => {
                let key = match input.get("key").and_then(|v| v.as_str()) {
                    Some(k) if !k.is_empty() => k,
                    _ => return err("INVALID_INPUT", "missing 'key'"),
                };
                let value = match input.get("value").and_then(|v| v.as_str()) {
                    Some(v) => v,
                    _ => return err("INVALID_INPUT", "missing 'value'"),
                };

                bindings::kv::put(key, value);
                ok(json!({ "ok": true }))
            }

            "del" => {
                let key = match input.get("key").and_then(|v| v.as_str()) {
                    Some(k) if !k.is_empty() => k,
                    _ => return err("INVALID_INPUT", "missing 'key'"),
                };
                bindings::kv::del(key);
                ok(json!({ "ok": true }))
            }

            _ => err("UNKNOWN_OPERATION", "unknown op"),
        }
    }
}

fn ok(result: Value) -> String {
    json!({"ok": true, "result": result}).to_string()
}

fn err(code: &str, message: &str) -> String {
    json!({"ok": false, "error": {"code": code, "message": message}}).to_string()
}
```

> Note: `bindings::kv::get/put/del` is the shape generated by `wit-bindgen` for imported interfaces. Run `cargo doc` on your service crate to see exact generated module names.

The kernel validates input/output against `service.json` schemas before and after invoking the service, so service-side validation can be light.

---

## 6) Building a service

From the service's `rust/` directory:

```bash
cargo component build --release
```

Then copy the output to `../service.wasm`. The `service build` command (§8) automates this.

---

## 7) `service new` command implementation

This kernel command scaffolds a new service. CLI surface is defined in [rust-kernel-reference.md §16](rust-kernel-reference.md).

Create: `crates/kernel/src/service_new.rs`

### What it does

1. Validate `category` and `name` are safe identifiers (`^[a-z][a-z0-9_-]{0,63}$`)
2. Create directory structure: `<service>/`, `<service>/rust/`, `<service>/rust/src/`, `<service>/rust/wit/`
3. Write scaffold files:
   - `service.json` (from template in §4.1)
   - `rust/Cargo.toml` (from template in §4.2)
   - `rust/src/lib.rs` (from template in §4.4)
   - `rust/wit/world.wit` (copy from `.octon/runtime/wit/world.wit`)

### File writing helper

```rust
fn write_file(path: &std::path::Path, contents: &str) -> std::io::Result<()> {
    if let Some(parent) = path.parent() { std::fs::create_dir_all(parent)?; }
    std::fs::write(path, contents)
}
```

---

## 8) `service build` command implementation

This kernel command builds a service's Rust crate into `service.wasm` and updates its integrity hash. CLI surface is defined in [rust-kernel-reference.md §16](rust-kernel-reference.md).

Create: `crates/kernel/src/service_build.rs`

### Build steps

1. Parse `id` as `<category>/<name>`
2. Locate service folder and `rust/` crate dir
3. Run `cargo component build --release` in `rust/`
4. Find the newest `.wasm` file under `rust/target/**/release/` (excluding `deps`)
5. Copy it to `<service>/service.wasm`
6. Compute SHA-256 and write it into `service.json` under `integrity.wasm_sha256`

### Running cargo-component

```rust
use std::process::Command;

let status = Command::new("cargo")
    .args(["component", "build", "--release"])
    .current_dir(&rust_dir)
    .status()?;

if !status.success() {
    return Err(anyhow::anyhow!("cargo component build failed"));
}
```

### Finding the output artifact

Walk `rust/target/`, keep `.wasm` files whose path contains `/release/` (or `\release\`), exclude paths containing `deps`, choose the most recently modified.

### SHA-256 + update `service.json`

Add `sha2` and `hex` to `crates/kernel/Cargo.toml`:

```toml
sha2 = "0.10"
hex = "0.4"
```

```rust
use sha2::{Digest, Sha256};

let bytes = std::fs::read(&service_wasm)?;
let hash = Sha256::digest(&bytes);
let wasm_sha256 = hex::encode(hash);

let mut v: serde_json::Value = serde_json::from_slice(&std::fs::read(&service_json)?)?;
v["integrity"]["wasm_sha256"] = serde_json::Value::String(wasm_sha256);
std::fs::write(&service_json, serde_json::to_vec_pretty(&v)?)?;
```

---

## 9) Developer workflow (end-to-end)

```bash
# scaffold a new service
.octon/runtime/run service new interfaces kv

# implement ops + update schemas
# edit service.json ops/schemas + rust/src/lib.rs

# build artifact + compute integrity hash
.octon/runtime/run service build interfaces/kv

# validate all services
.octon/runtime/run validate

# test end-to-end via CLI
.octon/runtime/run tool kv get --json '{"key": "test"}'
```

---

## 10) Rust targets note

If you choose not to use `cargo-component`, Rust has evolving support for WASI targets (including newer targets mentioned in wit-bindgen docs), but that changes fast. `cargo-component` is the most stable "one command builds a runnable component" path right now. ([GitHub][1])

[1]: https://github.com/bytecodealliance/cargo-component "GitHub - bytecodealliance/cargo-component"
[2]: https://component-model.bytecodealliance.org/language-support/rust.html "Rust - The WebAssembly Component Model"
