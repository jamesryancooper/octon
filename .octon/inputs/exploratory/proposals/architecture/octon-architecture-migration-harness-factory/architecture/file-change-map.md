# File Change Map

The manifest declares 38 exhaustive `.octon/**` promotion targets. A directory
target permits only the RP-11 entries/files described below, not semantic
ownership of the whole directory.

| # | Promotion target | Planned RP-11 change | Ownership boundary |
| ---: | --- | --- | --- |
| 1 | `.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.md` | Specify complete source graph, precedence, canonical bytes, receipt, and launch binding. | Harness compilation only; no policy/authority semantics. |
| 2 | `.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.schema.json` | Require exact complete effective manifest and ordered source refs. | Runtime schema mirror entry only. |
| 3 | `.octon/framework/engine/runtime/spec/task-specific-execution-harness-compile-receipt-v1.schema.json` | Bind compiler/schema/precedence, source root, effective digest, and launch identity. | Deterministic receipt contract only. |
| 4 | `.octon/framework/constitution/contracts/runtime/task-specific-execution-harness-v1.schema.json` | Mirror the accepted Harness contract exactly. | Constitutional mirror entry only. |
| 5 | `.octon/framework/constitution/contracts/runtime/task-specific-execution-harness-compile-receipt-v1.schema.json` | Mirror the accepted receipt contract exactly. | Constitutional mirror entry only. |
| 6 | `.octon/framework/constitution/contracts/runtime/family.yml` | Update exact Harness/receipt family entries and digests. | No unrelated family entries. |
| 7 | `.octon/framework/constitution/contracts/registry.yml` | Update exact Harness/receipt/adapter references required by RP-11. | No unrelated contract registrations. |
| 8 | `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Update exact topology/ownership entries for RP-11 contracts. | Discovery topology, not authority; exact entries only. |
| 9 | `.octon/framework/engine/runtime/spec/executor-profile-v1.schema.json` | Replace provider-name dispatch fields with strict adapter identity/ref binding where applicable. | Selection remains policy-owned. |
| 10 | `.octon/framework/constitution/contracts/adapters/model-adapter-v1.schema.json` | Require strict adapter identity/version/schema/conformance and declared lifecycle posture. | Model adapter declaration only. |
| 11 | `.octon/framework/constitution/contracts/adapters/host-adapter-v1.schema.json` | Require the same generic identity/lifecycle posture for host adapters. | Host adapter declaration only. |
| 12 | `.octon/framework/constitution/contracts/adapters/adapter-conformance-v1.schema.json` | Define executable six-operation fixture/result contract and evidence refs. | Generic component conformance only. |
| 13 | `.octon/framework/constitution/contracts/adapters/family.yml` | Publish exact adapter contract versions/digests. | No provider support admission. |
| 14 | `.octon/framework/engine/runtime/adapters/model/repo-local-governed.yml` | Align live declaration to strict schema and exact registry identity. | Availability declaration; not authority. |
| 15 | `.octon/framework/engine/runtime/adapters/model/frontier-governed.yml` | Align live declaration and mark only independently admitted live posture. | No automatic secondary-provider claim. |
| 16 | `.octon/framework/engine/runtime/adapters/host/` | Align existing host manifest fields and exact conformance refs. | Existing files only unless a new generic fixture manifest is necessary; no host effect specialization. |
| 17 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/adapter.rs` | Add `ExecutorAdapter`, `ExecutorAdapterRegistry`, typed prepared handles/outcomes, `resolve_adapter`, and sole generic dispatch. | RP-11 semantic ownership; RP-13 consumes but does not redefine. |
| 18 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/authorization.rs` | Extend existing `authorize_before_dispatch` inputs/checks with expected compiler/source/effective/adapter binding. | RP-01 authority predicates/decisions remain unchanged. |
| 19 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/context_pack.rs` | Produce deterministic explicit context source nodes/digests. | Context selection policy remains with source owner. |
| 20 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/generated.rs` | Verify exact generated/transitive source refs for compiler input. | Generated files remain projections. |
| 21 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/input_binding.rs` | Add `HarnessFactory`, `HarnessCompileRequest`, `HarnessSourceManifest`, `HarnessCompileReceiptBody`, `compile_harness`, and immediate pre-spawn revalidation; replace implicit defaults with typed complete bindings. | Pure compiler/binding only; no authority or ambient discovery. |
| 22 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs` | Carry compile request, exact Harness/source/receipt digests, and adapter identity. | No child-specific request semantics. |
| 23 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/result.rs` | Carry provider-neutral operation, usage, cancel, retire, and evidence refs. | Results are observations, not mission outcomes. |
| 24 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/observer.rs` | Normalize provider-neutral observations and identity checks. | No RP-08 reconciliation/recovery policy. |
| 25 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/codex.rs` | Implement the one real primary provider behind the generic trait. | No generic trait ownership and no verifier/publication semantics. |
| 26 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/claude.rs` | Remove direct live dispatch or retain only inactive trait-conforming code. | No live secondary without separate claim/proof. |
| 27 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/auto.rs` | Remove provider-name binary probing as dispatch; at most resolve an already-admitted adapter identity. | Policy selects; this module cannot authorize or choose opportunistically. |
| 28 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/mock.rs` | Supply fake lifecycle conformance adapters and negative fixtures. | Test-only; never live support. |
| 29 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/lib.rs` | Export compiler/adapter modules required by the generic seam. | Exact module exports only. |
| 30 | `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs` | Test registry, lifecycle methods, bypass denial, primary/fake component equivalence. | RP-11 component evidence only. |
| 31 | `.octon/framework/engine/runtime/crates/runtime_resolver/src/handles.rs` | Verify exact adapter and Harness/source handle identity/freshness as non-authoritative input. | Resolver does not compile or authorize. |
| 32 | `.octon/framework/engine/runtime/crates/runtime_resolver/src/lib.rs` | Expose verified typed refs needed by the Factory and remove executor-name authority. | Generated route bundles remain projections. |
| 33 | `.octon/instance/governance/policies/model-call-routing.yml` | Reference strict adapter identity and deterministic constraints. | Policy owner retains actual selection/admission; RP-11 changes exact binding fields only. |
| 34 | `.octon/framework/assurance/runtime/_ops/scripts/validate-workflow-statechart-harness.sh` | Add full source/effective/receipt binding and projection-boundary checks. | Assurance only; no compiler implementation. |
| 35 | `.octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh` | Validate exact model adapter identity and Harness binding. | No child mapping or support promotion. |
| 36 | `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh` | Deny direct provider dispatch, authority-shaped projections, and missing bindings. | Static/dynamic assurance only. |
| 37 | `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh` | Exercise strict manifest and six-operation conformance/bypass fixtures. | Generic component tests only. |
| 38 | `.octon/state/evidence/validation/proposals/octon-architecture-migration-harness-factory/` | Retain exact compiler, invalidation, binding, adapter, rollback, and review evidence. | Evidence owner writes bounded records; no raw secrets or authority. |

## Affected Outputs, Not Promotion Targets

- generated effective route bundles and resolver locks;
- per-run effective Harness/source manifests and compile receipts outside the
  retained validation bundle;
- provider-native raw payloads, processes, sessions, and operational logs;
- mission, run, candidate, evidence, and recovery state owned by other packets;
- `.octon/generated/proposals/registry.yml`.

These surfaces are regenerated, retained, or observed only through their
canonical owners. They cannot be edited as substitute source truth.

## Shared-File Integration Rule

The trusted integration lane serializes registry, policy, resolver, assurance,
and lifecycle-executor edits. Physical-file overlap never implies semantic
ownership: RP-11 changes only the exact entries/symbols above, RP-01 retains
authority semantics, and RP-06/RP-08/RP-13 retain specializations.
