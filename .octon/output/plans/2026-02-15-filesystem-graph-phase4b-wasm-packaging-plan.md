# Plan: Filesystem Graph Phase 4b WASM Packaging

## Context

`filesystem-graph` is implemented as shell-first and fully wired in harness service discovery.
Octon runtime executable discovery (`manifest.runtime.yml` / `registry.runtime.yml`) is wasm-only,
so runtime-tier registration requires a wasm-packaged service.

## Objective

Package filesystem-graph as a wasm component (`service.json` + `service.wasm`) without changing
existing contract semantics, then register it in runtime tiers.

## Non-Negotiables

1. No behavioral contract drift from shell implementation.
2. Same operation vocabulary and schema compatibility.
3. Runtime policy remains deny-by-default and fail-closed.
4. Snapshot artifacts remain source of derived graph state.

## Deliverables

1. New runtime service package:
- `.octon/capabilities/services/interfaces/filesystem-graph/service.json`
- `.octon/capabilities/services/interfaces/filesystem-graph/service.wasm`

2. Rust component scaffold:
- `.octon/capabilities/services/interfaces/filesystem-graph/rust/Cargo.toml`
- `.octon/capabilities/services/interfaces/filesystem-graph/rust/src/lib.rs`
- `.octon/capabilities/services/interfaces/filesystem-graph/rust/wit/world.wit`

3. Runtime registration:
- Update `.octon/capabilities/services/manifest.runtime.yml`
- Update `.octon/capabilities/services/registry.runtime.yml`
- Update `.octon/runtime/config/policy.yml` capability grants for `interfaces/filesystem-graph`

4. Compatibility and evidence updates:
- Add build/validation evidence under `.octon/runtime/_meta/evidence/`
- Update service `README.md` with wasm build and integrity update steps

## Capability Scope (initial)

- Required capabilities: `storage.local`, `log.write`
- Optional capability (if needed for direct fs host ops): `fs.read`

## Migration Sequence

1. Implement `invoke(op, input-json)` parity in Rust.
2. Reuse existing JSON schema validation semantics.
3. Build wasm and compute `integrity.wasm_sha256` in `service.json`.
4. Register runtime tier entries.
5. Run `octon validate` and runtime policy tests.
6. Keep shell entrypoint as fallback until parity verification is signed off.

## Exit Gate

1. `octon validate` passes with runtime tiers enabled.
2. `interfaces/filesystem-graph` appears in runtime service listing.
3. `tool.invoke` smoke tests pass for:
- `snapshot.get-current`
- `discover.start`
- `discover.resolve`
4. Integrity hash check passes for `service.wasm`.

## Risk Notes

- Adding `service.json` before producing `service.wasm` will break runtime discovery.
- Keep runtime registration changes in the same commit as wasm artifact generation.
