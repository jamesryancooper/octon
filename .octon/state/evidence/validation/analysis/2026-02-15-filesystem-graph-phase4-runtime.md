# Filesystem Graph Phase 4 Runtime Alignment

Date: 2026-02-15

## Runtime Alignment Outcome

1. `filesystem-graph` is registered in harness service discovery (`manifest.yml`, `registry.yml`).
2. Runtime executable registration (`manifest.runtime.yml`, `registry.runtime.yml`) remains wasm-only by contract.
3. `filesystem-graph` is implemented as shell-first for this phase and is adapter-neutral.

## Decision

Runtime wasm onboarding for filesystem-graph is deferred to a follow-up implementation that
packages the same contract into `service.json` + `service.wasm` without changing external semantics.

## Contract Safety

- No runtime-tier contract was violated.
- Native snapshot-first behavior is active and verifiable.
