# Rust Kernel Reference Implementation

This document is the **authoritative Rust host-side reference** for the Harmony executable layer kernel. It covers the workspace layout, canonical WIT contract, core types, module implementations, Wasmtime integration, and request execution pipeline.

> **Scope:** Host-side (kernel) only. For guest-side service authoring, see [rust-service-authoring.md](rust-service-authoring.md). For the sandboxed filesystem host API, see [rust-fs-host-api.md](rust-fs-host-api.md). For normative contracts, see [spec-bundle.md](spec-bundle.md).

---

## 1) Rust workspace layout

Inside `.harmony/runtime/` (or wherever you build the binary), structure it as a Rust workspace so you can keep the kernel clean and testable:

```text
.harmony/runtime/
  Cargo.toml                 # workspace
  wit/
    world.wit                # canonical WIT contract (shared by kernel + all services)
  crates/
    kernel/                  # the CLI binary crate
      Cargo.toml
      src/
        main.rs
        cli.rs
    core/                    # pure logic (no Wasmtime dependency leakage)
      Cargo.toml
      src/
        lib.rs
        root.rs              # RootResolver
        config.rs            # ConfigLoader
        discovery.rs         # ServiceDiscovery
        schema.rs            # JSON schema validation
        policy.rs            # PolicyEngine
        registry.rs          # ServiceRegistry types
        trace.rs             # TraceWriter
        errors.rs            # Error model + codes
        limits.rs            # Limits + enforcement helpers
        jsonlines.rs         # NDJSON read/write helpers
    wasm_host/               # Wasmtime integration
      Cargo.toml
      src/
        lib.rs
        host.rs              # WasmHost + instance cache
        bindings.rs          # generated bindings (wit-bindgen)
        state.rs             # HostState
        host_api.rs          # Host API implementations (log, clock, kv)
        scoped_fs.rs         # Sandboxed FS (see fs-implementation doc)
        kv_store.rs          # File-backed KV store
        policy.rs            # GrantSet
        invoke.rs            # Invoker bridging to wasm exports
        run_component.rs     # Linker wiring + instantiation
```

This separation prevents your domain logic from being entangled with Wasmtime, and makes it easier to unit test discovery/policy/tracing without executing Wasm.

---

## 2) Crate dependencies (recommended)

### `crates/kernel/Cargo.toml`

* `clap` (CLI)
* `anyhow` or your `core::errors`
* `serde`, `serde_json`
* `sha2`, `hex` (for `service build` integrity hashing)

### `crates/core/Cargo.toml`

* `serde`, `serde_yaml`, `serde_json`
* `jsonschema` (for validating `service.json` against your schema)
* `walkdir` (scan directories)
* `thiserror`
* `time` or `chrono` (timestamps)
* `uuid` (trace IDs)

### `crates/wasm_host/Cargo.toml`

* `wasmtime`
* `wasmtime-wasi`
* `wit-bindgen` (build-time codegen) + `wit-bindgen-rt`
* `serde`, `serde_json`
* `glob` (for `ScopedFs::glob`)
* `parking_lot` or `tokio` (if you want async; optional)

Wasmtime embedding is documented and stable.

---

## 3) Canonical WIT contract

> **This is the single source of truth for the WIT world.** Both the kernel (host bindings) and all services (guest bindings) use this definition. The file lives at `.harmony/runtime/wit/world.wit` and is copied into each service's `rust/wit/world.wit` at scaffold time.

```wit
package harmony:runtime@1.0.0;

world harmony-service {
  /// Host logging (capability-gated by the kernel).
  import log: interface {
    write: func(level: string, message: string);
  }

  /// Host clock (capability-gated by the kernel).
  import clock: interface {
    now-ms: func() -> u64;
  }

  /// Host KV (capability-gated by the kernel).
  import kv: interface {
    get: func(key: string) -> option<string>;
    put: func(key: string, value: string);
    del: func(key: string);
  }

  /// Host filesystem (capability-gated by the kernel, sandboxed to repo root).
  /// See rust-fs-host-api.md for implementation details.
  import fs: interface {
    // bytes
    read: func(path: string) -> list<u8>;
    write: func(path: string, data: list<u8>);

    // text (UTF-8)
    read-text: func(path: string) -> string;
    write-text: func(path: string, data: string);

    // queries
    exists: func(path: string) -> bool;
    list-dir: func(path: string) -> list<string>;
    glob: func(pattern: string) -> list<string>;

    // mutations
    mkdirp: func(path: string);
    remove-file: func(path: string);
    remove-dir-recursive: func(path: string);

    // metadata
    variant node-kind { file, dir }
    record stat {
      kind: node-kind,
      size: u64,
      modified-ms: option<u64>,
    }
    stat: func(path: string) -> option<stat>;
  }

  /// Generic op dispatcher.
  /// `input-json` and return value are UTF-8 JSON strings.
  export invoke: func(op: string, input-json: string) -> string;
}
```

### Why generic `invoke(op, json)` for v1

* You don't regenerate host bindings per-service op set
* Adding ops is a `service.json` + service code update only
* Your kernel remains the schema enforcer (validates input/output via `service.json` schemas)
* You can introduce fully typed per-op exports later without breaking v1

---

## 4) Core types (in `crates/core`)

### 4.1 Service manifest structs (serde)

```rust
pub struct ServiceManifestV1 {
  pub format_version: String,
  pub name: String,
  pub version: String,
  pub category: String,
  pub abi: String,
  pub entry: String,
  pub capabilities_required: Vec<String>,
  pub ops: std::collections::BTreeMap<String, OpDeclV1>,
  pub limits: LimitsV1,
  pub integrity: Option<IntegrityV1>,
  pub docs: Option<DocsV1>,
}

pub struct OpDeclV1 {
  pub input_schema: serde_json::Value,
  pub output_schema: serde_json::Value,
  pub idempotent: Option<bool>,
  pub streaming: Option<bool>,
}
```

### 4.2 Registry

```rust
pub struct ServiceKey {
  pub category: String,
  pub name: String,
}

pub struct ServiceDescriptor {
  pub key: ServiceKey,
  pub version: semver::Version,
  pub dir: std::path::PathBuf,
  pub wasm_path: std::path::PathBuf,
  pub manifest: ServiceManifestV1,
}
```

### 4.3 Error model

Use `thiserror` and map to the protocol codes defined in [spec-bundle.md §4.5](spec-bundle.md) (`CAPABILITY_DENIED`, `INVALID_INPUT`, `SERVICE_TRAP`, etc.).

---

## 5) Root resolution (nearest `.harmony/`)

`core/root.rs`:

* start from `cwd`
* walk parents until `.harmony/` exists
* return that path or error

This is pure and easy to test.

---

## 6) Service discovery (scan for `service.json`)

`core/discovery.rs`:

* scan `.harmony/capabilities/services/**/service.json` with `walkdir`
* parse + validate schema (see next section)
* compute `wasm_path = dir.join(entry)` and ensure it exists
* optional: verify `integrity.wasm_sha256`

Build `ServiceRegistry { by_key: HashMap<ServiceKey, ServiceDescriptor> }`

---

## 7) Schema validation (`service.json` against your schema)

`core/schema.rs`:

* load `.harmony/spec/service-manifest-v1.schema.json` (defined in [spec-bundle.md §1.3](spec-bundle.md))
* compile once per process using `jsonschema` crate
* validate every `service.json`
* return a structured error listing validation problems

This makes `harmony validate` meaningful and prevents unknown fields drifting into runtime.

---

## 8) Policy engine (deny-by-default)

`core/policy.rs`:

* takes:

  * caller context (optional for now; expand later to skill/workflow identity)
  * service descriptor (manifest declares required caps)
  * runtime config (allowed caps per service/category)
* returns `PolicyDecision`

Also enforce path sandbox:

* default workspace root = resolved `.harmony/` parent or repo root
* `fs.*` host APIs must reject paths outside workspace root (even if service asks)

```rust
pub enum PolicyDecision {
  Allow(GrantSet),
  Deny { code: String, message: String, details: serde_json::Value },
}
```

---

## 9) Tracing (NDJSON)

`core/trace.rs` + `core/jsonlines.rs`:

* open `state/traces/<trace_id>.ndjson` for append
* write JSON objects one per line
* events: request_received, policy_decision, invoke_start, invoke_end, error

NDJSON is ideal for streaming logs and append-only traces.

---

## 10) GrantSet (capability enforcement helper)

`wasm_host/policy.rs`:

```rust
use std::collections::BTreeSet;

#[derive(Clone, Debug)]
pub struct GrantSet {
    caps: BTreeSet<String>,
}

impl GrantSet {
    pub fn new<I, S>(caps: I) -> Self
    where
        I: IntoIterator<Item = S>,
        S: Into<String>,
    {
        Self {
            caps: caps.into_iter().map(Into::into).collect(),
        }
    }

    pub fn has(&self, cap: &str) -> bool {
        self.caps.contains(cap)
    }

    /// Returns Ok(()) if capability is granted, or a typed error
    /// that the kernel maps to CAPABILITY_DENIED at the protocol layer.
    pub fn require(&self, cap: &str) -> wasmtime::Result<()> {
        if self.has(cap) {
            Ok(())
        } else {
            Err(anyhow::anyhow!("CAPABILITY_DENIED: missing {cap}").into())
        }
    }
}
```

---

## 11) KvStore (file-backed JSON map)

`wasm_host/kv_store.rs`:

```rust
use std::{
    collections::BTreeMap,
    fs,
    io::{self, Read, Write},
    path::{Path, PathBuf},
    sync::{Arc, Mutex},
};

#[derive(Clone)]
pub struct KvStore {
    inner: Arc<Mutex<Inner>>,
}

struct Inner {
    file_path: PathBuf,
    map: BTreeMap<String, String>,
}

impl KvStore {
    /// Opens (or creates) a KV store at `state_dir` (e.g. `.harmony/state/kv/`).
    /// Stores data in `store.json` as a JSON object: { "key": "value", ... }.
    pub fn open(state_dir: PathBuf) -> io::Result<Self> {
        fs::create_dir_all(&state_dir)?;
        let file_path = state_dir.join("store.json");

        let map = if file_path.exists() {
            load_json_map(&file_path)?
        } else {
            BTreeMap::new()
        };

        Ok(Self {
            inner: Arc::new(Mutex::new(Inner { file_path, map })),
        })
    }

    pub fn get(&self, key: &str) -> io::Result<Option<String>> {
        validate_key(key)?;
        let inner = self.inner.lock().map_err(|_| io_err("mutex poisoned"))?;
        Ok(inner.map.get(key).cloned())
    }

    pub fn put(&self, key: &str, value: &str) -> io::Result<()> {
        validate_key(key)?;
        validate_value(value)?;
        let mut inner = self.inner.lock().map_err(|_| io_err("mutex poisoned"))?;
        inner.map.insert(key.to_string(), value.to_string());
        persist_atomic(&inner.file_path, &inner.map)
    }

    pub fn del(&self, key: &str) -> io::Result<bool> {
        validate_key(key)?;
        let mut inner = self.inner.lock().map_err(|_| io_err("mutex poisoned"))?;
        let existed = inner.map.remove(key).is_some();
        if existed {
            persist_atomic(&inner.file_path, &inner.map)?;
        }
        Ok(existed)
    }

    pub fn len(&self) -> io::Result<usize> {
        let inner = self.inner.lock().map_err(|_| io_err("mutex poisoned"))?;
        Ok(inner.map.len())
    }
}

fn load_json_map(path: &Path) -> io::Result<BTreeMap<String, String>> {
    let mut f = fs::File::open(path)?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    if s.trim().is_empty() {
        return Ok(BTreeMap::new());
    }
    serde_json::from_str::<BTreeMap<String, String>>(&s)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, format!("invalid JSON: {e}")))
}

fn persist_atomic(path: &Path, map: &BTreeMap<String, String>) -> io::Result<()> {
    let dir = path.parent().ok_or_else(|| io_err("missing parent dir"))?;
    fs::create_dir_all(dir)?;

    let tmp = temp_path(path);
    let bytes = serde_json::to_vec(map)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, format!("serialize error: {e}")))?;

    {
        let mut f = fs::File::create(&tmp)?;
        f.write_all(&bytes)?;
        f.sync_all()?;
    }

    #[cfg(windows)]
    {
        if path.exists() {
            fs::remove_file(path)?;
        }
    }

    fs::rename(&tmp, path)?;
    fsync_dir_best_effort(dir);
    Ok(())
}

fn validate_key(key: &str) -> io::Result<()> {
    if key.is_empty() {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "key is empty"));
    }
    if key.len() > 256 {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "key too long"));
    }
    if key.chars().any(|c| c == '\n' || c == '\r' || c == '\0') {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "key contains invalid characters"));
    }
    Ok(())
}

fn validate_value(value: &str) -> io::Result<()> {
    if value.len() > 1_000_000 {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "value too large"));
    }
    if value.chars().any(|c| c == '\0') {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "value contains invalid characters"));
    }
    Ok(())
}
```

### Shared atomic-write utilities

The following helpers are used by both `KvStore` and `ScopedFs` (see [rust-fs-host-api.md](rust-fs-host-api.md)). Place them in a shared module or duplicate in each:

```rust
fn temp_path(path: &Path) -> PathBuf {
    let mut p = path.to_path_buf();
    let pid = std::process::id();
    let nanos = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos();
    let file_name = format!(
        "{}.tmp.{}.{}",
        path.file_name().and_then(|x| x.to_str()).unwrap_or("file"),
        pid,
        nanos
    );
    p.set_file_name(file_name);
    p
}

fn fsync_dir_best_effort(dir: &Path) {
    #[cfg(unix)]
    {
        use std::os::unix::fs::OpenOptionsExt;
        if let Ok(f) = fs::OpenOptions::new().read(true).custom_flags(libc::O_DIRECTORY).open(dir) {
            let _ = f.sync_all();
        }
    }
}

fn io_err(msg: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, msg.to_string())
}
```

---

## 12) HostState (canonical definition)

> **This is the single definition of `HostState`.** All host API implementations operate on this struct.

`wasm_host/state.rs`:

```rust
use wasmtime::component::ResourceTable;
use wasmtime_wasi::p2::{WasiCtx, WasiView};

use crate::kv_store::KvStore;
use crate::policy::GrantSet;
use crate::scoped_fs::ScopedFs;

pub struct HostState {
    pub wasi_ctx: WasiCtx,
    pub table: ResourceTable,

    // Harmony-specific state
    pub grants: GrantSet,
    pub kv: KvStore,
    pub fs: ScopedFs,
}

impl WasiView for HostState {
    fn ctx(&mut self) -> &mut WasiCtx {
        &mut self.wasi_ctx
    }

    fn table(&mut self) -> &mut ResourceTable {
        &mut self.table
    }
}
```

Construction:

```rust
let repo_root = harmony_dir.parent().unwrap().to_path_buf();
let kv = KvStore::open(harmony_dir.join("state").join("kv"))?;
let fs = ScopedFs::new(repo_root.clone())?;
let grants = GrantSet::new(/* capabilities from policy engine */);
```

---

## 13) Host API implementations (log, clock, kv)

`wasm_host/host_api.rs`:

```rust
use crate::bindings::{clock, kv, log};
use crate::state::HostState;

impl log::Host for HostState {
    fn write(&mut self, level: String, message: String) -> wasmtime::Result<()> {
        self.grants.require("log.write")?;
        eprintln!("[{level}] {message}");
        Ok(())
    }
}

impl clock::Host for HostState {
    fn now_ms(&mut self) -> wasmtime::Result<u64> {
        self.grants.require("clock.read")?;
        Ok(std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis() as u64)
    }
}

impl kv::Host for HostState {
    fn get(&mut self, key: String) -> wasmtime::Result<Option<String>> {
        self.grants.require("storage.local")?;
        Ok(self.kv.get(&key)?)
    }

    fn put(&mut self, key: String, value: String) -> wasmtime::Result<()> {
        self.grants.require("storage.local")?;
        self.kv.put(&key, &value)?;
        Ok(())
    }

    fn del(&mut self, key: String) -> wasmtime::Result<()> {
        self.grants.require("storage.local")?;
        let _ = self.kv.del(&key)?;
        Ok(())
    }
}
```

> For the `fs::Host` implementation, see [rust-fs-host-api.md](rust-fs-host-api.md). It follows the same pattern: capability-gate via `self.grants.require(...)`, then delegate to `self.fs.*`.

---

## 14) Wasmtime bindings + linker wiring

### 14.1 Generate host bindings from WIT

`wasm_host/bindings.rs`:

```rust
use wasmtime::component::bindgen;

bindgen!({
    world: "harmony-service",
    path: "../../wit", // points at .harmony/runtime/wit/
});
```

> Tip: set `WASMTIME_DEBUG_BINDGEN=1` to dump generated code to disk for inspection.

### 14.2 WasmHost structure

```rust
pub struct WasmHost {
    engine: wasmtime::Engine,
    linker: wasmtime::component::Linker<HostState>,
    // Optional: cache compiled components
}
```

Configure `wasmtime::Engine` with caching pointed at `.harmony/state/wasmtime-cache/`.

### 14.3 Linker wiring + instantiation + calling `invoke`

For WASI Preview2 components, add WASI interfaces to your component `Linker` via `wasmtime_wasi::p2::add_to_linker_sync`. ([docs.wasmtime.dev][1])

`wasm_host/run_component.rs`:

```rust
use wasmtime::{Engine, Result, Store};
use wasmtime::component::{Component, Linker, HasSelf, ResourceTable};
use wasmtime_wasi::p2::{WasiCtx, WasiCtxBuilder, add_to_linker_sync};

use crate::bindings::HarmonyService;
use crate::state::HostState;

pub fn invoke_component(
    engine: &Engine,
    wasm_path: &std::path::Path,
    state: HostState,
    op: &str,
    input_json: &str,
) -> Result<String> {
    let component = Component::from_file(engine, wasm_path)?;
    let mut linker: Linker<HostState> = Linker::new(engine);

    // Provide WASI Preview2 imports
    add_to_linker_sync(&mut linker)?;

    // Provide Harmony host imports from the generated bindings
    HarmonyService::add_to_linker::<_, HasSelf<_>>(&mut linker, |s| s)?;

    // Create store
    let mut store = Store::new(engine, state);

    // Instantiate
    let bindings = HarmonyService::instantiate(&mut store, &component, &linker)?;

    // Call exported top-level function `invoke`
    let out = bindings.call_invoke(&mut store, op, input_json)?;
    Ok(out)
}
```

---

## 15) Invoker (schema validation wrapper)

`wasm_host/invoke.rs`:

* validates input JSON vs `input_schema` (from `service.json`)
* calls `invoke_component(...)` (above)
* validates output JSON vs `output_schema`
* enforces `max_response_bytes`

---

## 16) Kernel CLI

`crates/kernel/src/cli.rs`:

```rust
use clap::{Parser, Subcommand};

#[derive(Parser)]
pub struct Cli {
    #[command(subcommand)]
    pub cmd: Command,
}

#[derive(Subcommand)]
pub enum Command {
    Info { #[arg(long)] json: bool },
    Services { #[command(subcommand)] cmd: ServicesCmd },
    Tool { service: String, op: String, #[arg(long)] json: String },
    Validate,
    ServeStdio,
    Service { #[command(subcommand)] cmd: ServiceCmd },
}

#[derive(Subcommand)]
pub enum ServicesCmd {
    List { #[arg(long)] json: bool },
}

#[derive(Subcommand)]
pub enum ServiceCmd {
    New { category: String, name: String, #[arg(long)] summary: Option<String> },
    Build { id: String },
}
```

> For `service new`/`service build` implementation details (scaffolding templates, build process, integrity hashing), see [rust-service-authoring.md](rust-service-authoring.md).

---

## 17) Request execution pipeline

For both CLI `tool` and stdio `tool.invoke`, the flow is identical:

1. `RootResolver` → active `.harmony/`
2. `ConfigLoader` → policy config + paths
3. `ServiceDiscovery` → find `ServiceDescriptor`
4. `PolicyEngine` → `Allow(GrantSet)` or `Deny`
5. `TraceWriter` → log request + decision
6. `WasmHost` → instantiate component with `HostState { grants, kv, fs, … }`
7. `Invoker` → schema-validate input, invoke, validate output
8. `TraceWriter` → log completion/error
9. return JSON response

---

## 18) Smoke test (KvStore unit test)

```rust
#[cfg(test)]
mod tests {
    use super::KvStore;
    use std::fs;
    use std::path::PathBuf;

    #[test]
    fn persists_put_get_del() {
        let dir = PathBuf::from("target/tmp-kv-test");
        let _ = fs::remove_dir_all(&dir);

        let kv = KvStore::open(dir.clone()).unwrap();
        kv.put("a", "1").unwrap();
        assert_eq!(kv.get("a").unwrap(), Some("1".to_string()));

        // new instance sees persisted data
        let kv2 = KvStore::open(dir.clone()).unwrap();
        assert_eq!(kv2.get("a").unwrap(), Some("1".to_string()));

        assert_eq!(kv2.del("a").unwrap(), true);
        assert_eq!(kv2.get("a").unwrap(), None);
    }
}
```

[1]: https://docs.wasmtime.dev/ "Introduction - Wasmtime"
