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

## Context Pack Builder

Deterministic Context Pack Builder v1 is documented under
`spec/context-pack-builder-v1.md`. It defines the pre-authorization context
assembly contract for consequential or boundary-sensitive Runs and remains
subordinate to `authorize_execution(...)`.

The builder contract emits retained context evidence:

- a `context-pack-v1` artifact governed by
  `/.octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json`
- a `context-pack-receipt-v1` artifact governed by
  `spec/context-pack-receipt-v1.schema.json`
- the exact retained model-visible serialization at
  `/.octon/state/evidence/runs/<run-id>/context/model-visible-context.json`
- the SHA-256 digest of that exact serialization at
  `/.octon/state/evidence/runs/<run-id>/context/model-visible-context.sha256`
- source, omission, redaction, and invalidation manifests under the same
  retained context evidence root

Mutable control truth records only the active binding under
`/.octon/state/control/execution/runs/<run-id>/context/active-context-pack.yml`
and `status.yml`. Control truth is not retained proof.

Execution requests, grants, and execution receipts bind the same
`context_evidence_binding` fields, including `model_visible_context_ref` and
`model_visible_context_sha256`, so context evidence cannot be rewritten to widen
authority after assembly. Repo-local packing rules live at
`/.octon/instance/governance/policies/context-packing.yml`; support-target
requirements remain narrow-only and do not admit new support. Raw
`inputs/**`, generated views, host UI state, chat history, and proposal files
may be cited only as non-authoritative context and must not become runtime or
policy dependencies.

Replay verifies the model-visible hash from the retained
`model-visible-context.json` bytes, not from source-manifest lines alone. Stale,
invalidated, missing, mismatched, proposal-local, generated-authority, or
raw-authority context evidence fails closed before material authorization.

Canonical Run Journal context lifecycle events are hyphenated:
`context-pack-requested`, `context-pack-built`, `context-pack-bound`,
`context-pack-rejected`, `context-pack-compacted`,
`context-pack-invalidated`, and `context-pack-rebuilt`. Dot-named
`runtime-event-v1` forms are compatibility aliases only and are not emitted by
canonical journal writers.

The runtime assurance entrypoint for pack/receipt/replay validation is
`/.octon/framework/assurance/runtime/_ops/scripts/validate-context-pack-builder.sh`,
with regression coverage in
`/.octon/framework/assurance/runtime/_ops/tests/test-context-pack-builder.sh`
and fixtures under
`/.octon/framework/assurance/runtime/_ops/fixtures/context-pack-builder-v1`.

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

- `spec/run-journal-v1.md`
- `spec/execution-request-v3.schema.json`
- `spec/execution-grant-v1.schema.json`
- `spec/execution-receipt-v3.schema.json`
- `spec/execution-authorization-v1.md`
- `spec/authorization-boundary-coverage-v1.md`
- `spec/context-pack-builder-v1.md`
- `spec/context-pack-receipt-v1.schema.json`
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

The canonical append-only execution history for a consequential run is the Run
Journal:

- `events.ndjson` is the canonical event stream
- `events.manifest.yml` is the canonical journal manifest
- `runtime-state.yml` is the mutable derived view over that journal
- `runtime_bus` is the sole canonical append path
- retained journal closeout snapshots live under
  `state/evidence/runs/<run-id>/run-journal/**`

events.ndjson is the canonical event stream for consequential run execution.

Generated/operator views may summarize lifecycle and closeout state, but they
remain derived-only and non-authoritative.
