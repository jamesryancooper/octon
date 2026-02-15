# Runtime

Executable runtime layer for harness-native service invocation.

## Contents

| Path | Purpose |
|---|---|
| `run` | POSIX launcher entrypoint |
| `run.cmd` | Windows launcher entrypoint |
| `config/` | Runtime policy and cache configuration |
| `crates/` | Runtime implementation crates |
| `spec/` | Runtime protocol and schema contracts |
| `wit/` | Canonical runtime WIT contracts |
| `_ops/bin/` | Runtime-local prebuilt binaries |
| `_ops/state/` | Runtime-local mutable state (cache/traces/kv) |
| `_meta/evidence/` | Verification artifacts and implementation evidence |

## Contract

- Keep runtime structural assets under `config/`, `crates/`, `spec/`, and `wit/`.
- Keep mutable operational data under `_ops/state/`.
- Keep audit/verification documents under `_meta/evidence/`.
