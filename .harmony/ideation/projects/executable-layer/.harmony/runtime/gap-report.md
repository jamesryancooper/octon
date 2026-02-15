# Gap report

This report lists anything **deferred, stubbed, or simplified** relative to the v1 spec bundle and implementation architecture.

## Fuel / memory limits

- **Fuel:** Not wired. The kernel does not configure fuel consumption (`Config::consume_fuel`) nor does it set per-call fuel budgets.
- **Memory:** Not explicitly capped beyond what Wasmtime defaults and component/WASI require. There is no per-instance linear-memory limit configuration.

Status: **Deferred** (explicitly called out as optional in the spec). Timeout enforcement is implemented via epoch interruption.

## Streaming ops / events

- The service manifest supports `streaming: true` on ops.
- The kernel **does not implement streaming op semantics** (no incremental `event` messages sourced from guest execution).
- The stdio server only emits `response` and `error` messages.

Status: **Deferred**.

## TraceWriter

- A functional `TraceWriter` exists at `.harmony/runtime/crates/core/src/trace.rs`.
- It writes NDJSON trace events to `.harmony/state/traces/<trace_id>.ndjson`.
- The stdio server creates a trace writer per invocation when possible (`kernel/src/stdio.rs`).

Limitations:
- No redaction policy is enforced (values may be written as provided).
- Trace fields are minimal and not a stable schema.

Status: **Functional but minimal**.

## `integrity.wasm_sha256` verification

- Implemented when `integrity.wasm_sha256` is a string.
- If missing or `null`, verification is skipped.

Status: **Implemented**.

## `harmony run --spec` workflow execution

- Not implemented.
- The kernel does not interpret or execute higher-level workflow specs.

Status: **Deferred**.

## Stdio server safety: stdin/stdout

- The kernel does **not** inherit host stdio into guest WASI, to protect NDJSON protocol output on stdout.
- Guests should use `log.write` for logging (writes to stderr).

Status: **Implemented**.

## NDJSON request size enforcement

- The server enforces a max line length (default 1 MiB) in `.harmony/runtime/crates/core/src/jsonlines.rs`.

Limitation:
- `BufRead::read_line` can temporarily allocate beyond the cap before the length check occurs.

Status: **Implemented with a known limitation**.

## Service tier metadata YAML

- Example `manifest.yml` and `registry.yml` are present under `.harmony/capabilities/services/`.
- The runtime loader does **not** require or enforce these files.

Status: **Deferred for runtime enforcement** (treated as harness metadata in v1).

