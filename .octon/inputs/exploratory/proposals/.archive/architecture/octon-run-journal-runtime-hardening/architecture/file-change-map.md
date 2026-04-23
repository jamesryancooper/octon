# File Change Map

This proposal targets `.octon/**` only. It does not mix non-`.octon/**`
promotion targets into the active proposal.

## Constitutional runtime contracts

| Path | Change shape | Purpose |
|---|---|---|
| `.octon/framework/constitution/contracts/runtime/run-event-v2.schema.json` | Add | Canonical typed event envelope with sequence, causal refs, actor refs, hash links, authority refs, evidence refs, and redaction metadata. |
| `.octon/framework/constitution/contracts/runtime/run-event-ledger-v2.schema.json` | Add | Ledger manifest with integrity, first/last refs, hash-chain status, count, schema refs, snapshot refs, and drift state. |
| `.octon/framework/constitution/contracts/runtime/runtime-state-v2.schema.json` | Add | Derived runtime-state view with last-applied event and drift status. |
| `.octon/framework/constitution/contracts/runtime/state-reconstruction-v2.md` | Add | Operational reconstruction algorithm and conflict rule. |
| `.octon/framework/constitution/contracts/runtime/family.yml` | Modify | Register v2 contracts and migration notes. |
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Modify | Register promoted v2 runtime contracts. |

## Runtime engine specs

| Path | Change shape | Purpose |
|---|---|---|
| `.octon/framework/engine/runtime/spec/run-journal-v1.md` | Add | Engine-facing implementation contract for canonical journal append/replay behavior. |
| `.octon/framework/engine/runtime/spec/runtime-event-v1.schema.json` | Modify | Normalize dot-named runtime events into canonical run-event family or declare explicit legacy aliases. |
| `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | Modify | Tie lifecycle transitions to required event types and runtime-state derivation. |
| `.octon/framework/engine/runtime/spec/evidence-store-v1.md` | Modify | Require journal snapshot/hash match for closeout evidence. |
| `.octon/framework/engine/runtime/spec/operator-read-models-v1.md` | Modify | Require operator views to cite journal/evidence roots and non-authority classification. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md` | Modify | Require journal coverage for material path families. |
| `.octon/framework/engine/runtime/README.md` | Modify | Document Run Journal as execution substrate and CLI behavior. |

## Runtime implementation surfaces

| Path | Change shape | Purpose |
|---|---|---|
| `.octon/framework/engine/runtime/crates/runtime_bus/**` | Modify | Single append path; event validation; sequence/hash enforcement. |
| `.octon/framework/engine/runtime/crates/replay_store/**` | Modify | Journal-first reconstruction and dry-run replay default. |
| `.octon/framework/engine/runtime/crates/telemetry_sink/**` | Modify | Mirror telemetry from journal without authority. |
| `.octon/framework/engine/runtime/crates/authority_engine/**` | Modify | Emit authority events and enforce journal refs before side effects. |
| `.octon/framework/engine/runtime/crates/assurance_tools/**` | Modify/Add | Add journal integrity and reconstruction validators if housed in crate. |

## Assurance and validation

| Path | Change shape | Purpose |
|---|---|---|
| `.octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-contracts.sh` | Add | Validate schemas, event aliasing, lifecycle mapping, reconstruction, and generated-view non-authority. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh` | Modify | Invoke Run Journal validator. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-docs-consistency.sh` | Modify | Check runtime docs and schemas stay aligned. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-support-target-admission.sh` | Add/Modify | Require valid journal evidence for supported consequential tuples. |

## Governance and support-target surfaces

| Path | Change shape | Purpose |
|---|---|---|
| `.octon/instance/governance/support-targets.yml` | Modify | Add Run Journal conformance as admission/promotion requirement. |
| `.octon/instance/governance/policies/mission-autonomy.yml` | Modify if needed | Ensure pause/resume/checkpoint/intervention events are required for Mission autonomy transitions. |

## Generated outputs

Generated surfaces must be rebuilt only after promotion and validation.

| Path family | Rule |
|---|---|
| `.octon/generated/**` | Derived-only; may render support matrix, operator summaries, proposal registry, and runtime read models. Must not become authority. |
