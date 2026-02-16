# Flow — Harness-Native Flow Execution Service

Flow is the execution service bridge. It validates typed flow run requests,
executes workflow manifests natively in the Harmony runtime by default, writes
deterministic run records, and optionally forwards to an external LangGraph
HTTP runtime when explicitly configured.

## Purpose

- Accept typed flow run requests.
- Validate required config fields and workflow artifacts.
- Execute via native adapter (`native-harmony`) by default.
- Optionally call an external runtime (`langgraph-http`) through `/flows/run`.
- Emit deterministic run ids and run records for traceability.

## Runtime Artifacts

- Runtime manifest: `service.json`
- Runtime component: `service.wasm`
- Rust source: `rust/`
- Input schema: `schema/input.schema.json`
- Output schema: `schema/output.schema.json`

## Adapters

- Registry: `adapters/registry.yml`
- Native adapter: `adapters/native-harmony/`
- Optional external adapter: `adapters/langgraph-http/`
- Contract validator: `impl/validate-adapters.sh`

## Native-First Policy

- Core flow execution does not depend on Python.
- Native adapter is default and is deterministic for identical inputs.
- External runtime use is optional and capability-gated (`net.http`).

## Operation

- `run`

## Contract Artifacts

- Invariants: `contracts/invariants.md`
- Errors: `contracts/errors.yml`
- Rules: `rules/rules.yml`
- Fixtures: `fixtures/`
- Compatibility: `compatibility.yml`
- Generation provenance: `impl/generated.manifest.json`
