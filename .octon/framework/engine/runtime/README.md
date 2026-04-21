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

## Authority Engine

`crates/authority_engine/src/implementation.rs` is the facade for the runtime
authority surface. The implementation now lives under
`crates/authority_engine/src/implementation/` in auditable modules aligned to
stable concepts:

- `api.rs`: public request, grant, receipt, and executor surface types
- `records.rs`: retained runtime, support-target, and authority record shapes
- `common.rs`: shared filesystem, path, and decision helpers
- `runtime_state.rs`: canonical run-root binding and lifecycle synchronization
- `support.rs`: ownership, support-target, adapter, and capability-pack routing
- `authority.rs`: approval, revocation, decision, and grant artifact emission
- `autonomy.rs`: mission-backed autonomy resolution
- `policy.rs`: ACP receipt composition, budget, and egress enforcement
- `execution.rs`: authorization orchestration and execution artifact materialization

The authority engine is anchored to the runtime spec surfaces under `spec/`,
especially:

- `spec/execution-request-v3.schema.json`
- `spec/execution-grant-v1.schema.json`
- `spec/execution-receipt-v3.schema.json`
- `spec/execution-authorization-v1.md`
- `spec/authorization-boundary-coverage-v1.md`
- `spec/evidence-store-v1.md`
- `spec/run-lifecycle-v1.md`
- `spec/operator-read-models-v1.md`
- `spec/promotion-activation-v1.md`
- `spec/policy-interface-v1.md`
- `spec/policy-receipt-v2.schema.json`
- `spec/policy-digest-v2.md`

## Packaging Contract

- `release-targets.yml` is the single source of truth for runtime target ids,
  binary names, artifact names, and shippable-release expectations.
- `OCTON_RUNTIME_STRICT_PACKAGING=1` disables source fallback for declared
  runtime targets and fails when a required packaged binary is absent.
- `OCTON_RUNTIME_PREFER_SOURCE=1` still allows local source-first execution
  only when strict packaging mode is disabled.

## Operator Surfaces

The engine runtime now exposes run-first operator surfaces through the shared
`octon` CLI:

- `octon run start --contract <run-contract>`
- `octon run inspect --run-id <run-id>`
- `octon run resume --run-id <run-id>`
- `octon run checkpoint --run-id <run-id>`
- `octon run close --run-id <run-id>`
- `octon run replay --run-id <run-id>`
- `octon run disclose --run-id <run-id>`

`octon workflow run ...` is not a live consequential execution lane. Use
`octon run start --contract <run-contract>` instead.

The runtime also exposes orchestration operator inspection through the same
CLI and Studio host:

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
