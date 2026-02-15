# Executable Layer Implementation Architecture

Below is the **implementation architecture** for a portable, stack-agnostic, OS-agnostic, self-contained agent harness that ships **multiple OS/arch binaries** and supports **typed "services" implemented as WebAssembly components** hosted by an embedded runtime.

> This document covers implementation-level concerns: repository layout, portability rules, cross-OS bootstrap, runtime choice, enforcement model, CLI surface, caching, and an implementation checklist. For normative contract definitions (`service.json`, NDJSON protocol, discovery YAML, error codes, capability identifiers, kernel module architecture), see [spec-bundle.md](spec-bundle.md).

---

## 1) Repository layout

```text
.harmony/
  harmony.yml
  START.md
  scope.md
  conventions.md
  catalog.md

  runtime/
    run                 # POSIX sh launcher
    run.cmd             # Windows launcher
    bin/
      harmony-darwin-arm64
      harmony-darwin-x64
      harmony-linux-arm64
      harmony-linux-x64
      harmony-windows-x64.exe
    config/
      wasmtime-cache.toml
    README.md

  capabilities/
    services/
      manifest.yml       # discovery tier 1 (lightweight index)
      registry.yml       # discovery tier 2 (extended metadata)
      agent-platform/
        kv/
          service.wasm
          service.json
        policy/
          service.wasm
          service.json
      retrieval/
        search/
          service.wasm
          service.json

  state/
    wasmtime-cache/
    traces/
    kv/
    indexes/
```

### Design notes

- **`.harmony/runtime/`** contains the executable runtime and its launchers.
- **`.harmony/capabilities/services/<category>/<service>/`** is the unit of deployment for a service: one folder per service, containing its WASM artifact + runtime manifest (`service.json` — format defined in [spec-bundle.md §1](spec-bundle.md)).
- **`.harmony/state/`** is runtime state (caches, traces, indexes). Keep it **gitignored** and **non-portable**.

---

## 2) Portability rules

Portability is metadata-driven, not structural. The following classifications belong in `harmony.yml`.

### Portable (framework assets)

- `.harmony/runtime/**` (launcher scripts + binaries)
- `.harmony/capabilities/services/**/service.wasm`
- `.harmony/capabilities/services/**/service.json`
- `.harmony/capabilities/services/manifest.yml`
- `.harmony/capabilities/services/registry.yml`

### Non-portable (project-local state)

- `.harmony/state/**` (caches, traces, indexes, KV backing store)
- `.harmony/continuity/**` (progress, tasks, session state)
- Repo-specific missions, decisions, and analyses

All non-portable paths should be gitignored.

---

## 3) Execution entrypoints (cross-OS bootstrap)

### `.harmony/runtime/run` (POSIX `sh`)

Responsibilities:

- resolve the harness directory
- detect OS/arch (`uname`)
- choose the matching binary under `runtime/bin/`
- `exec` that binary with forwarded args

### `.harmony/runtime/run.cmd` (Windows `cmd`)

Responsibilities:

- resolve harness directory
- detect the *actual* OS architecture robustly using `PROCESSOR_ARCHITECTURE` and `PROCESSOR_ARCHITEW6432` (important for WOW64 cases) ([SS64][1])
- launch `runtime/bin/harmony-windows-x64.exe` (and optionally arm64 in the future)

Both launchers assume only the OS-native command runner exists (`sh` on Unix, `cmd` on Windows) — no Python, Node, or other runtime dependencies.

---

## 4) Kernel (native binary) responsibilities

The kernel binary (the thing in `runtime/bin/`) acts as the **agent runtime host**. Its logical modules and data flow are defined in [spec-bundle.md §5](spec-bundle.md). At a high level, the kernel provides:

1. **Harness root resolution** — "nearest `.harmony/` ancestor wins" for nested scopes
2. **Service discovery** — scans `capabilities/services/**/service.json`, builds in-memory registry, optionally caches a snapshot (see §8)
3. **Service execution host** — loads `service.wasm`, instantiates via Wasmtime with WASI + host APIs
4. **Capability enforcement** — deny-by-default, two-gate model (see §6)
5. **Observability** — structured traces to `.harmony/state/traces/*.ndjson`

### Architectural constraints

- The kernel never listens on a port.
- The kernel never backgrounds itself.

---

## 5) WebAssembly runtime choice

### Recommended host: **Wasmtime**

Why it fits this architecture:

- Wasmtime documents WASI as providing a *secure and portable* way to access OS-like features (filesystems, clocks, etc.), and positions the Component Model as portable cross-language composition. ([docs.wasmtime.dev][2])
- It supports hosting component-style interfaces and is a common reference runtime for WASI/component-model workflows. ([component-model.bytecodealliance.org][3])

### Embedding model

Wasmtime is embedded as a library inside the kernel binary, not invoked as a standalone tool. This keeps the deployment unit self-contained (single binary per OS/arch).

### Default security posture

By default, Wasmtime denies components access to system resources (filesystem, environment variables, network). This matches the harness's deny-by-default invariants — the host must explicitly grant each capability.

> For the full list of v1 capability identifiers, see [spec-bundle.md §7](spec-bundle.md). For the Rust implementation of host APIs, see [rust-kernel-reference.md](rust-kernel-reference.md) and [rust-fs-host-api.md](rust-fs-host-api.md).

---

## 6) Two-gate capability enforcement model

Services do **not** access OS resources directly. They request host-provided APIs, and the kernel mediates access. The Component Model expects the platform to provide well-defined APIs for things components need (stdin, env vars, sockets, etc.). ([component-model.bytecodealliance.org][3])

Capability enforcement operates through two complementary gates:

### Gate A: Harmony governance (existing model)

- Skills and commands declare allowlisted tools/services.
- Deny-by-default; unknown capabilities fail closed.
- HITL and no-silent-apply gates apply at this layer.

### Gate B: Runtime capability engine

Before invoking a service operation, the kernel checks:

1. Does the caller have permission per the Harmony governance layer?
2. Does the service declare the required capabilities in its `service.json`?
3. Does the active policy allow those capabilities for this service and scope?

All three checks must pass. Failure at any gate denies the invocation.

### Filesystem sandboxing

- Default: allow read/write only under the resolved repo root.
- Explicit policy required to escape scope or follow symlinks outside the repo boundary.

### Policy sources

- `harmony.yml` and/or a dedicated policy file under `.harmony/runtime/config/`
- category-level defaults (e.g., retrieval services may allow read-only FS)
- per-service overrides (for narrowly scoped exceptions)

---

## 7) CLI surface (human + automation friendly)

Recommended command set:

- `harmony info [--json]`
- `harmony services list [--json]`
- `harmony tool <service> <op> --json '<payload>'`
- `harmony run --spec <path>` (executes agent plan/workflow graph)
- `harmony validate` (validates manifests, policies, and service artifacts)
- `harmony serve-stdio` (NDJSON session mode — protocol defined in [spec-bundle.md §4](spec-bundle.md))
- `harmony service new <category> <name>` (scaffold a new service)
- `harmony service build <category>/<name>` (build service.wasm + update integrity hash)

> For `serve-stdio` protocol details, see [spec-bundle.md §4](spec-bundle.md). For Rust CLI implementation, see [rust-kernel-reference.md](rust-kernel-reference.md). For `service new`/`service build` implementation details, see [rust-service-authoring.md](rust-service-authoring.md).

---

## 8) Caching, state, and performance

### Wasmtime compilation cache

Configure Wasmtime to write its compilation cache under:

- `.harmony/state/wasmtime-cache/`

Wasmtime supports caching compiled artifacts to speed subsequent runs (configure via a cache config file such as TOML). ([docs.wasmtime.dev][2])

Disk-cached compilation artifacts give repeated single-shot invocations near-warm startup without requiring a background process.

### Registry snapshot cache

The kernel may optionally write a registry snapshot to `.harmony/state/registry-cache.json` after scanning `capabilities/services/**/service.json`. On subsequent invocations, this snapshot accelerates service discovery by avoiding a full filesystem scan when the snapshot is fresh.

### Harness runtime state

- `.harmony/state/kv/` for service-backed state
- `.harmony/state/indexes/` for search/vector/etc. indexes
- `.harmony/state/traces/` for NDJSON traces

All state directories are gitignored and non-portable.

---

## 9) Progressive disclosure integration

- **Tier 1 (`capabilities/services/manifest.yml`)**: minimal identifiers, triggers, summaries.
- **Tier 2 (`capabilities/services/registry.yml`)**: extended metadata (risk tier, dependencies, I/O paths, recommended approvals).
- **Activation-time**: kernel loads `service.json` + `service.wasm` only when a service is invoked.

This keeps cold-start scanning lightweight while preserving deep metadata when needed. Tier 1/2 YAML formats are defined in [spec-bundle.md §2-3](spec-bundle.md).

---

## 10) Implementation checklist

### A) Runtime

- [ ] `run` (POSIX sh launcher)
- [ ] `run.cmd` (Windows cmd launcher)
- [ ] Per-OS/arch kernel binaries (`harmony-{os}-{arch}`)
- [ ] Wasmtime cache config pointing to `.harmony/state/wasmtime-cache/`

### B) Kernel

- [ ] `.harmony/` root resolver (nearest-harness rule)
- [ ] Service discovery: scan `capabilities/services/**/service.json`
- [ ] Wasmtime component host integration (embed as library)
- [ ] Capability/policy engine (two-gate enforcement)
- [ ] Filesystem sandboxing (scoped to repo root)
- [ ] NDJSON stdio session mode (`serve-stdio`)
- [ ] Tracing output to `.harmony/state/traces/*.ndjson`

### C) Service authoring

- [ ] Template for `service.json` (minimum contract)
- [ ] Build convention for producing `service.wasm` (WASI component target)
- [ ] `service new` scaffolding command
- [ ] `service build` build + integrity hash command

[1]: https://ss64.com/nt/syntax-64bit.html "Detect 64 vs 32 bit OS or Process - Windows CMD - SS64.com"
[2]: https://docs.wasmtime.dev/ "Introduction - Wasmtime"
[3]: https://component-model.bytecodealliance.org/running-components/wasmtime.html "Wasmtime - The WebAssembly Component Model"
