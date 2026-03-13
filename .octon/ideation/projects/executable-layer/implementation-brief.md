# Octon Executable Runtime Layer: Implementation Brief

## What you're receiving

You are receiving a bundle of 7 specification and reference documents that define a **portable WebAssembly-based executable runtime layer** for an existing agent harness called Octon.

Octon is a repo-wide agent harness — a structured collection of markdown files, YAML manifests, and scripts that govern AI-assisted software development. Today it is metadata-only: agents read contracts and produce proposals, but the harness itself cannot execute code. Your job is to change that.

The 7 documents are listed below in reading order. Read them in this sequence — each builds on the previous:

| # | File | What it covers |
|---|------|----------------|
| 1 | `harness-overview.md` | The existing Octon harness — structure, governance, discovery model, architectural principles. Read this first for context. |
| 2 | `executable-layer-gains.md` | Why an executable layer is being added — the 9 capabilities it unlocks. |
| 3 | `spec-bundle.md` | **Authoritative v1 contracts.** `service.json` format + JSON Schema, Tier 1/2 discovery YAML, NDJSON stdio protocol, kernel module architecture (conceptual), capability identifiers, error codes. **This document wins if anything conflicts.** |
| 4 | `executable-layer-implementation-architecture.md` | Implementation architecture — repo layout, cross-OS bootstrap, Wasmtime rationale, two-gate capability enforcement, CLI surface, caching strategy, implementation checklist. |
| 5 | `rust-kernel-reference.md` | Rust host-side kernel reference — workspace layout, canonical WIT contract, core types (HostState, GrantSet, KvStore), host API implementations, Wasmtime linker wiring, CLI structure, request pipeline. |
| 6 | `rust-fs-host-api.md` | Sandboxed filesystem host API — ScopedFs struct, path sanitization, symlink escape prevention, atomic writes, `fs::Host` trait implementation. |
| 7 | `rust-service-authoring.md` | Guest-side service authoring — `cargo-component` toolchain, service ABI, folder structure, template files, KV reference service, `service new`/`service build` commands. |

## What we are trying to accomplish

Build a working v1 runtime that can:

1. **Load** WebAssembly component services from `.octon/capabilities/services/<category>/<service>/`
2. **Validate** inputs and outputs against JSON Schemas declared in each service's `service.json`
3. **Enforce** deny-by-default capability policies (services get nothing unless explicitly granted)
4. **Invoke** services through a generic `invoke(op, input_json) -> output_json` ABI
5. **Communicate** over NDJSON stdio protocol (session mode) or direct CLI commands
6. **Run** on macOS, Linux, and Windows from a single codebase with cross-OS bootstrap scripts

The runtime is a Rust binary (the "kernel") that embeds Wasmtime as a library. Services are WebAssembly components built with `cargo-component`. The kernel mediates all access to OS resources through host-provided APIs.

## What to do

**Implement from the spec as written.** The 7 documents are your inputs, not your outputs — do not modify or expand them. Where the spec is ambiguous, make a reasonable choice and record it in the decision log (see deliverables below).

### Implementation scope

Build the following, in this order:

1. **Canonical WIT file** at `.octon/runtime/wit/world.wit` — must match `rust-kernel-reference.md` §3 exactly
2. **Rust workspace** under `.octon/runtime/crates/` with the kernel binary crate
3. **Core types**: RootResolver, ConfigLoader, ServiceDiscovery, PolicyEngine (per `spec-bundle.md` §5)
4. **Host APIs**: log, clock, kv, fs — with GrantSet enforcement on every call
5. **ScopedFs**: sandboxed filesystem with path traversal prevention, symlink escape prevention, and atomic writes
6. **WasmHost**: Wasmtime integration with compilation caching under `.octon/runtime/_ops/state/wasmtime-cache/`
7. **Invoker**: input validation → Wasm call → output validation pipeline
8. **NDJSON stdio server** (`serve-stdio`): hello handshake, request/response, events, cancellation
9. **CLI commands**: `info`, `services list`, `tool`, `validate`, `serve-stdio`, `service new`, `service build`
10. **Bootstrap scripts**: `run` (POSIX sh) and `run.cmd` (Windows) at `.octon/runtime/`
11. **JSON Schema file** at `.octon/runtime/spec/service-manifest-v1.schema.json`
12. **Reference KV service** at `.octon/capabilities/services/interfaces/kv/` — fully buildable with `cargo component build`

### What NOT to do

- Do not modify the 7 spec documents
- Do not add capabilities, ops, or host APIs beyond what the spec defines for v1
- Do not introduce external services, databases, or network dependencies — the runtime is fully local
- Do not over-engineer for v2 — build the minimum that satisfies v1 contracts
- Do not skip output validation (this is the most commonly dropped requirement)

## What to deliver

### Code

The complete `.octon/runtime/` directory and the reference KV service, structured so that `cargo check --workspace` passes from the workspace root. Also deliver the bootstrap scripts and the JSON Schema file.

Include the output of:
- `cargo check --workspace` (from `crates/`)
- `cargo component check` (from the reference KV service's `rust/` directory)

### Three documents (alongside the code)

**1. Decision log**

Every place the spec was ambiguous and you chose an approach. Format:

```markdown
| # | Decision | Options considered | Choice | Rationale |
|---|----------|--------------------|--------|-----------|
| 1 | Policy config file format | YAML vs TOML vs JSON | ... | ... |
| 2 | Concurrency enforcement | Semaphore vs reject vs queue | ... | ... |
```

**2. Compliance matrix**

Maps every MUST/normative requirement from `spec-bundle.md` to the specific file and line (or function) where it's implemented. This is how I will verify completeness. Format:

```markdown
| # | Requirement (from spec-bundle.md) | Location | Status |
|---|-----------------------------------|----------|--------|
| 1 | format_version must match exactly (§1.2) | crates/kernel/src/discovery.rs:45 | Done |
| 2 | Input MUST be validated against input_schema before invoking (§1.2) | crates/kernel/src/invoker.rs:22 | Done |
```

Cover at minimum:
- All "MUST" behaviors in §1.2 (service.json enforcement)
- Protocol rules in §4 (hello handshake, cancellation, all 12 error codes)
- Module responsibilities in §5
- All v1 capability identifiers in §7

**3. Gap report**

Anything deferred, stubbed, or simplified. Be honest — an explicit gap is more useful than a hidden shortcut. Specifically address:
- Fuel/memory limits (optional per spec but state whether wired)
- Streaming ops (event path)
- TraceWriter (is it functional or stubbed?)
- `integrity.wasm_sha256` verification at load time
- `octon run --spec` (workflow execution — likely deferred)

## Verification test scenarios

The implementation should handle these scenarios correctly. Include tests or demonstrate them manually:

| Scenario | Expected result |
|----------|-----------------|
| Hello handshake (valid) | Kernel responds with `hello` + version info |
| Hello handshake (wrong protocol) | `PROTOCOL_UNSUPPORTED` error |
| KV put → get → del → get | Round-trip succeeds; final get returns null |
| Unknown service | `UNKNOWN_SERVICE` error |
| Unknown op on valid service | `UNKNOWN_OPERATION` error |
| Input fails schema validation | `INVALID_INPUT` error |
| Service requests ungrantable capability | `CAPABILITY_DENIED` error |
| Service exceeds timeout | `TIMEOUT` error |

## Security checklist (ScopedFs)

Confirm with code references that:
- Path traversal (`../`) is blocked after canonicalization
- Symlink escape outside workspace root is prevented
- Write operations use atomic write (write-to-temp + rename)
- All `fs::Host` methods check `GrantSet` before executing
- `fs.read` and `fs.write` are separate capabilities (a service with `fs.read` cannot write)
