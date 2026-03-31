# Source Of Truth Map

| Concern | Current live signal | Promotion target(s) | Proposal-local source |
| --- | --- | --- | --- |
| Service authorization boundary | `/.octon/framework/engine/runtime/crates/kernel/src/main.rs` | `main.rs`, `authority_engine/src/implementation.rs`, runtime execution spec | `architecture/target-architecture.md#shared-execution-authorization-boundary` |
| Workflow dispatch and stage execution | `/.octon/framework/engine/runtime/crates/kernel/src/main.rs`, `/.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs` | `main.rs`, `pipeline.rs`, `workflow.rs`, new execution contracts | `architecture/target-architecture.md#workflow-stage-authorization` |
| Workflow evidence bundle layout | `/.octon/state/evidence/runs/workflows/` and workflow bundle files under `reports/`, `stage-inputs/`, and `stage-logs/` | `/.octon/state/evidence/runs/`, execution receipt schema, assurance checks | `architecture/target-architecture.md#symmetric-evidence-and-receipts` |
| Root fail-closed claim | `/.octon/octon.yml` | `/.octon/octon.yml`, runtime architecture docs, protected-mode checks | `architecture/target-architecture.md#protected-environment-enforcement` |
| Current policy intent and receipt contract | `/.octon/framework/engine/runtime/spec/policy-interface-v1.md` | new execution authorization and receipt specs that compose with existing policy receipts | `architecture/target-architecture.md#execution-contracts` |
| External executor launch surface | `/.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs` and provider launch helpers | `workflow.rs`, executor wrapper layer, executor profile schema | `architecture/target-architecture.md#executor-containment-contract` |
| Protected CI and review gates | `/.github/workflows/ai-review-gate.yml`, `/.github/workflows/pr-autonomy-policy.yml`, `/.github/workflows/release-please.yml`, `/.github/workflows/deny-by-default-gates.yml` | workflow guards, assurance checks, protected-mode summaries | `architecture/target-architecture.md#ci-and-release-guard-contract` |
| Canonical architecture authority | `/.octon/framework/cognition/_meta/architecture/specification.md`, `runtime-policy.md`, `runtime-vs-ops-contract.md` | same durable architecture surfaces | `architecture/target-architecture.md` and `architecture/acceptance-criteria.md` |
