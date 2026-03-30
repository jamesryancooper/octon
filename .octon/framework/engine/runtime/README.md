# Engine Runtime

`runtime/` contains executable runtime artifacts only.

## Contents

- `run` / `run.cmd`: launcher entrypoints
- `policy` / `policy.cmd`: policy-engine launcher interface
- `release-targets.yml`: canonical runtime target matrix for launchers and
  release automation
- `adapters/`: replaceable host and model adapter manifests
- `crates/`: runtime implementations
- `config/`: runtime-local configuration (including `policy-interface.yml`)
- `spec/`: runtime schema/protocol contracts
- `wit/`: canonical WIT contracts

## Packaging Contract

- `release-targets.yml` is the single source of truth for runtime target ids,
  binary names, artifact names, and shippable-release expectations.
- `OCTON_RUNTIME_STRICT_PACKAGING=1` disables source fallback for declared
  runtime targets and fails when a required packaged binary is absent.
- `OCTON_RUNTIME_PREFER_SOURCE=1` still allows local source-first execution
  only when strict packaging mode is disabled.

## Operator Surfaces

The engine runtime now exposes orchestration operator inspection through the
shared `octon` CLI and Studio host:

- `octon orchestration lookup ...`
- `octon orchestration summary --surface ...`
- `octon orchestration incident closure-readiness --incident-id <id>`
- `.octon/framework/engine/runtime/run studio`

These are read-only operator surfaces over canonical orchestration and
continuity artifacts. They do not create new execution authority.

## Runtime Lifecycle

Consequential execution binds one canonical run control root under
`/.octon/state/control/execution/runs/<run-id>/` and one canonical evidence
root under `/.octon/state/evidence/runs/<run-id>/` before side effects occur.
Canonical run manifests, receipts, checkpoints, replay pointers, evidence
classification, and rollback posture remain under the bound run root;
deprecated compatibility artifacts are retired.
