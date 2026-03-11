# Engine Runtime

`runtime/` contains executable runtime artifacts only.

## Contents

- `run` / `run.cmd`: launcher entrypoints
- `policy` / `policy.cmd`: policy-engine launcher interface
- `crates/`: runtime implementations
- `config/`: runtime-local configuration (including `policy-interface.yml`)
- `spec/`: runtime schema/protocol contracts
- `wit/`: canonical WIT contracts

## Operator Surfaces

The engine runtime now exposes orchestration operator inspection through the
shared `harmony` CLI and Studio host:

- `harmony orchestration lookup ...`
- `harmony orchestration summary --surface ...`
- `harmony orchestration incident closure-readiness --incident-id <id>`
- `.harmony/engine/runtime/run studio`

These are read-only operator surfaces over canonical orchestration and
continuity artifacts. They do not create new execution authority.
