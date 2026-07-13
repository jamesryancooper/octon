# File Change Map

The manifest declares 44 exhaustive `.octon/**` promotion targets. Directory
and shared-file targets are limited to the RP-13 entries, symbols, and tests
named below. A target declaration is planning scope, not implementation
authorization.

| # | Promotion target | Planned RP-13 change | Ownership boundary |
| ---: | --- | --- | --- |
| 1 | `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | Add temporary MissionChildRun references, cancellation/reconciliation handoff, and retirement state constraints. | References RP-08 recovery; does not redefine run authority or store transitions. |
| 2 | `.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.md` | Require exact child/role/scope/budget/isolation/provider-mapping bindings for a child Harness. | RP-11 owns generic Harness semantics; RP-13 adds narrowing child fields only. |
| 3 | `.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.schema.json` | Validate the child-specific optional binding block and reject unknown or widening fields. | Runtime mirror only; generic compile and guard semantics remain RP-11. |
| 4 | `.octon/framework/constitution/contracts/runtime/task-specific-execution-harness-v1.schema.json` | Mirror the child-specific schema fields. | Must remain byte/semantic parity with the runtime schema through its owner. |
| 5 | `.octon/framework/engine/runtime/spec/agent-node-v1.md` | Describe temporary mission-child lineage, depth one, and non-authority. | Agent Node remains model activity, not a scheduler, account, or authority source. |
| 6 | `.octon/framework/engine/runtime/spec/agent-node-v1.schema.json` | Add strict temporary child lineage and depth references. | No persistent-agent or role-authority fields. |
| 7 | `.octon/framework/constitution/contracts/runtime/agent-node-v1.schema.json` | Mirror the temporary child lineage fields. | Contract mirror only. |
| 8 | `.octon/framework/engine/runtime/spec/mission-child-run-v1.md` | Define MissionChildRun identity, strict intersection, lifecycle, candidate-only output, cancellation, reconciliation, and retirement. | New RP-13 semantic source; never aliases ProgramChild. |
| 9 | `.octon/framework/engine/runtime/spec/mission-child-run-v1.schema.json` | Add strict MissionChildRun instance schema. | RP-13 owns temporary child fields only. |
| 10 | `.octon/framework/constitution/contracts/runtime/mission-child-run-v1.schema.json` | Add canonical mirror of the MissionChildRun schema. | Mirror must not introduce authority. |
| 11 | `.octon/framework/engine/runtime/spec/mission-child-budget-v1.schema.json` | Define per-dimension hard, measurement-only, or unsupported posture and exact remaining-limit intersection. | Token ledger measurement cannot be promoted to enforcement by schema text. |
| 12 | `.octon/framework/constitution/contracts/runtime/mission-child-budget-v1.schema.json` | Add canonical mirror of the child budget schema. | Contract mirror only. |
| 13 | `.octon/framework/engine/runtime/spec/mission-child-terminal-retirement-v1.schema.json` | Define preserved output/evidence, revocation/release, tombstone, and reuse-denial receipt fields. | Consumes RP-08 terminal reconciliation; does not define recovery truth. |
| 14 | `.octon/framework/constitution/contracts/runtime/mission-child-terminal-retirement-v1.schema.json` | Add canonical mirror of terminal retirement schema. | Contract mirror only. |
| 15 | `.octon/framework/engine/runtime/spec/mission-child-provider-mapping-v1.schema.json` | Define child-specific prepare/launch/observe/cancel/usage/retire binding and outcome fields. | Specialization over RP-11 generic adapter only. |
| 16 | `.octon/framework/constitution/contracts/adapters/mission-child-provider-mapping-v1.schema.json` | Add canonical adapter-contract mirror. | Cannot alter the generic adapter trait or support policy. |
| 17 | `.octon/framework/engine/runtime/spec/token-budget-ledger-v1.md` | Record child budget identity, provider usage provenance, and enforcement classification. | Ledger remains measurement evidence and non-authority. |
| 18 | `.octon/framework/engine/runtime/spec/token-budget-ledger-v1.schema.json` | Validate child identity and hard/measured/unsupported provenance fields. | No authorization or unsupported hard-limit claim. |
| 19 | `.octon/framework/constitution/contracts/runtime/family.yml` | Register MissionChildRun, child budget, and terminal retirement contracts. | Registry entries only; no new runtime family. |
| 20 | `.octon/framework/constitution/contracts/adapters/family.yml` | Register the MissionChildProviderMapping specialization. | Generic adapter registration remains RP-11-owned. |
| 21 | `.octon/framework/constitution/contracts/registry.yml` | Add exact contract IDs, versions, owners, and mirrors. | Shared registry integration must serialize exact RP-13 entries. |
| 22 | `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | Publish matching architecture metadata for the new contracts. | Discovery projection; not runtime authority. |
| 23 | `.octon/instance/governance/policies/mission-child-agents.yml` | Record accepted depth-one/role-template boundaries, accepted ROD-005 provisional resource limits, proof-derived enforcement classes and admitted mappings, and disabled-by-default posture. | Engineering binds conservative enforceable values; later tuning is governed configuration; no credentials or grants. |
| 24 | `.octon/instance/governance/policies/token-budgets.yml` | Add provisional child budget ceilings and enforcement references under the accepted ROD-005 baseline. | Existing policy extended only for child entries; dogfood may justify one-dimension-at-a-time widening. |
| 25 | `.octon/framework/scaffolding/runtime/templates/octon/instance/governance/policies/mission-child-agents.yml` | Provide a deny-by-default template with no live mapping or operator choice. | Template is inert and cannot imply provider support. |
| 26 | `.octon/framework/engine/runtime/adapters/children/` | Add child mapping descriptors and conformance fixtures for fake and conditionally admitted primary mappings. | No second registry, generic adapter, or provider credential store. |
| 27 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/child.rs` | Map exact MissionChildRun contract to RP-11 generic operations and validate child-specific outcomes. | RP-13-owned specialization; generic trait untouched. |
| 28 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/child_codex.rs` | Map conditionally admitted primary-provider child behavior without exporting session material or enabling provider-side descendants. | Provider-specific child module only; `codex.rs` and support policy remain RP-11. |
| 29 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/lib.rs` | Export the child specialization module. | One exact module/export entry; no generic semantic edits. |
| 30 | `.octon/framework/engine/runtime/crates/lifecycle_executor/src/token_budget.rs` | Carry child budget identity, usage provenance, and enforce/measured/unsupported observations. | Does not claim measurement as hard enforcement. |
| 31 | `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/child.rs` | Test mapping, guard binding, credential/depth denial, limit posture, cancel/unknown, and retirement observations. | Child specialization tests only. |
| 32 | `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs` | Expose/reuse exact batch, lock, counter, retry, timeout, cancel, and terminal hooks for MissionChildRun jobs. | ProgramChild types and proposal lifecycle semantics remain unchanged; no new scheduler. |
| 33 | `.octon/framework/engine/runtime/crates/kernel/src/mission_child.rs` | Implement MissionChildRun identity, intersection/admission, scheduler mapping, cancellation/reconciliation handoff, output reconciliation, and terminal retirement. | New RP-13 module; authority/store/recovery predicates remain foreign. |
| 34 | `.octon/framework/engine/runtime/crates/kernel/src/commands/mission.rs` | Fold concise child progress and exact cancellation into existing mission UX. | No child-administration command family. |
| 35 | `.octon/framework/engine/runtime/crates/kernel/src/main.rs` | Register only the existing mission command's child status/cancel surface. | Exact command wiring; no daemon, queue, or service. |
| 36 | `.octon/framework/engine/runtime/crates/kernel/tests/mission_child.rs` | Exercise strict scope/depth/limits, scheduling, cancellation, unknown reconciliation, output, retirement, replacement, and ProgramChild separation. | RP-13 integration tests; RP-08/RP-11 contracts used as frozen interfaces. |
| 37 | `.octon/framework/assurance/runtime/_ops/scripts/validate-mission-child-agent-contract.sh` | Add the complete MissionChildRun contract/ownership/invariant gate. | Assurance only; cannot authorize launch. |
| 38 | `.octon/framework/assurance/runtime/_ops/scripts/validate-workflow-statechart-harness.sh` | Validate exact optional child Harness bindings and depth/no-spawn posture. | Existing Harness validator receives RP-13 assertions only. |
| 39 | `.octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh` | Validate temporary child lineage and role non-authority. | No change to generic model-call authority semantics. |
| 40 | `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh` | Validate child policy, guard, mapping, and no-direct-effect boundaries. | Consumes existing authority/broker validators; no duplicated policy engine. |
| 41 | `.octon/framework/assurance/runtime/_ops/scripts/validate-token-budget-ledger.sh` | Validate child usage provenance and hard-versus-measurement truthfulness. | Does not turn ledger data into enforcement. |
| 42 | `.octon/framework/assurance/runtime/_ops/tests/test-mission-child-agent-contract.sh` | Add adversarial credential, Git, sibling, scope, depth, guard, provider, cancel, unknown, retirement, and reuse cases. | UE-013 proof fixture only. |
| 43 | `.octon/framework/assurance/runtime/_ops/tests/test-token-budget-ledger.sh` | Add hard/measured/unsupported child-budget cases and forged/missing-usage denial. | Budget evidence tests only. |
| 44 | `.octon/state/evidence/validation/proposals/octon-architecture-migration-bounded-child-agents/` | Retain bounded ROD-005, dependency, UE-013, mapping, cancellation, reconciliation, retirement, UX, and review evidence. | Evidence is non-authority; no credentials, session material, or unbounded logs. |

## Affected Outputs, Not Promotion Targets

- child control instances under the existing mission/run control boundary;
- disposable child candidate repositories and session/process handles;
- child output, usage, cancellation, unknown-outcome, retirement, and tombstone
  evidence instances;
- mission status/inbox generated views;
- RP-08 reconciliation and RP-11 Harness/adapter receipts consumed by exact
  reference; and
- `.octon/generated/proposals/registry.yml`.

These surfaces are created or refreshed only through their canonical owners.
They do not become proposal authority, reusable agent records, or a second
control plane.

## Shared-File Integration Rule

The trusted integration lane serializes shared registries, Harness/Agent Node,
run-lifecycle, lifecycle-executor exports, scheduler hooks, mission command
wiring, token ledger, and assurance changes. RP-13 owns only the child entries,
modules, symbols, and assertions listed above. A required edit to RP-08 recovery
truth, RP-11 generic adapter/guard semantics, RP-02 isolation/session mechanics,
or core authority/store transitions blocks RP-13 and routes to that owner.
