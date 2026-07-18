# Planned Source Ownership Map

| Packet | Exclusive semantic ownership | Explicit exclusions/handoffs |
| --- | --- | --- |
| RP-00 | containment, hard-disable slices for unsafe current publication/cleanup entrypoints, writer/launcher/credential/trust/provider-workflow inventories, claim correction | no final route policy, broker/store/verifier implementation, or presumption that current PR is safe |
| RP-01 | authority semantics, typed scopes, decision receipts, exact guard API, and the final guard-invocation/bypass-removal slice at the four census-owned candidate launch seams | RP-03 persistence; RP-02 isolation; RP-04 effects/credentials; RP-11 Harness/adapter; RP-13 budgets |
| RP-02 | candidate-isolation module/native host policy/disposable repo export | RP-01 guard; RP-11 generic adapter; RP-04 credentials |
| RP-03 | SQLite schema/migrations, one store mutation API, T1/outbox/T2, backup/restore | RP-08 provider outcome classification; RP-07 evidence policy |
| RP-04 | broker core, IPC, Keychain, supervision, operation handles, sole deployed writer/effect host | no authority mint/verdict; RP-05 Git; RP-07 evidence; RP-08 reconciliation |
| RP-05 | closed non-executing Git/ref primitives: exact-object import, source-ref expected-absent/expected-tip create/update, target `O -> S` CAS, expected-tip delete, and fast-forward mirror primitive | no route, history, PR, cleanup-eligibility, outcome, or recovery policy; never a generic Git service |
| RP-06 | immutable route taxonomy/predicate, history policy, exact `V`, protected-PR semantics, `S -> Q` proof, publication postconditions, local-main mirror orchestration, and `.octon` workflow projection owner | no candidate-held verifier, grant issuance, Git credential custody, signed evidence, outcome classification, or recovery |
| RP-07 | signed grant/verdict/operation/provider/landed/reconciliation/terminal evidence, checkpoint/head/retention/reserve/compaction, monotonic anchor, and exact evidence adapters | consumes RP-03 store/outbox; no authorization, route, effect, cleanup, or store-schema authority |
| RP-08 | provider outcome classifier, UNKNOWN reconciliation, retry eligibility, manual intervention, conditional cleanup lifecycle/status, run health/maintenance, reversible vertical | consumes frozen RP-03 transitions, RP-06 route/landed facts, and RP-05 conditional primitive |
| RP-09 | semantic trust inventory, inert install, selector/health/rollback activation | consumes prior safety spine; no same-change authority |
| RP-10 | project identity/profile/location/inbox symbols | project metadata is non-authority; RP-11 Harness |
| RP-11 | Harness compiler, generic adapter trait/manifests/conformance | RP-06/RP-08/RP-13 specializations |
| RP-12 | signed private extension envelope/catalog/pin/quarantine/revoke/restore | import never authorizes/selects |
| RP-13 | child identity/scope/budget/mapping/cancel/retire modules | RP-11 generic adapter; existing scheduler; no authority/store changes |
| RP-14 | retained proof protocol/results/claim map/handoff only | no runtime/workflow/CLI/validator/provider/support source |

Shared physical files are not shared semantic ownership. Exact modules, symbols,
schema/registry entries, and manifest rows are assigned above and edited
serially through one trusted integration lane. In particular: RP-01 semantics
freeze before RP-03 persistence; `lifecycle_executor` is partitioned among
RP-01 authorization, RP-02 isolation, RP-11 generic adapter, RP-13 child mapping;
`local_broker` is partitioned among RP-04 core, RP-05 Git, and RP-07 evidence.
RP-08 owns a separate credentialless `effect_reconciler` library that cannot
open credentials, dispatch effects, or become a writer. Global Cargo/contract
registries have one integration writer and packet-owned exact entries.

## RP-01 Candidate-Launch Invocation Ownership

| Exact target | RP-01-owned slice | Preserved ownership |
| --- | --- | --- |
| `.octon/framework/engine/runtime/crates/kernel/src/pipeline.rs` | `run_codex`, `run_claude`, and `run_with_stdin`: invoke the exact consuming guard immediately before spawn and remove raw bypasses. | Pipeline, prompt, command construction, output, and budget semantics remain unchanged. |
| `.octon/framework/engine/runtime/crates/kernel/src/workflow.rs` | `WorkflowExecutor::execute_stage_codex`, `WorkflowExecutor::execute_stage_claude`, and `run_command_with_stdin`: invoke the exact consuming guard immediately before spawn and remove raw bypasses. | Workflow/stage, prompt, command construction, effect, and budget semantics remain unchanged. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/codex.rs` | `run_with_timeout`: invoke the exact consuming guard immediately before Codex/Claude spawn and remove raw bypasses. | RP-02 retains isolation and RP-11 retains generic adapter/Harness semantics. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/workflow_leaf.rs` | `run_workflow_command`: invoke the exact consuming guard immediately before leaf-runtime spawn and remove raw bypasses. | Workflow resolution, child identity, Harness, and evidence semantics remain unchanged. |
| `.octon/framework/assurance/runtime/_ops/tests/test-authorization-boundary-coverage.sh`; `.octon/framework/assurance/runtime/_ops/tests/test-authorization-boundary-negative-controls.sh`; `.octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-coverage-fixtures.sh` | Closed census, raw-spawn rejection, and four-seam guard-dominance fitness only. | No child gains general assurance-test ownership beyond its declared proof slice. |

## Brokered Publication Responsibility Decisions

| Decision | Sole semantic owner | Bounded consumers/contributors |
| --- | --- | --- |
| `BNP-OWN-001` candidate source-ref create/update | RP-05 | RP-06 supplies a policy-bound request; RP-08 classifies/reconciles. |
| `BNP-OWN-002` target-main `O -> S` CAS | RP-05 | RP-04 hosts the effect; RP-08 classifies/reconciles. |
| `BNP-OWN-003` immutable route taxonomy/predicate | RP-06 | RP-01 supplies generic grant fields; RP-03 freezes the selected digest. |
| `BNP-OWN-004` exact candidate verification and `V` | RP-06 | RP-07 authenticates the resulting evidence reference. |
| `BNP-OWN-005` protected-PR create/update/merge semantics | RP-06 | RP-04 hosts closed effects; RP-05 supplies only ref primitives; RP-08 reconciles. |
| `BNP-OWN-006` `S -> Q` provider association and tree/patch proof | RP-06 | RP-07 signs the independent observation. |
| `BNP-OWN-007` provider-result classification | RP-08 | RP-05/RP-06 supply direct observations. |
| `BNP-OWN-008` `UNKNOWN` reconciliation and no-retry rule | RP-08 | RP-03 preserves attempt truth; RP-04 cannot retry independently. |
| `BNP-OWN-009` hosted-main to canonical-local-main mirror orchestration | RP-06 | RP-05 may supply the closed fast-forward primitive; RP-08 records failure outcome. |
| `BNP-OWN-010` conditional cleanup lifecycle, eligibility, and status | RP-08 | RP-06 supplies route-specific landed facts; RP-05 supplies expected-tip deletion only. |
| `BNP-OWN-011` history-shape policy | RP-06 | RP-05 validates/imports the admitted closure but does not select shape. |
| `BNP-OWN-012` signed terminal evidence and monotonic anchor | RP-07 | All producers remain role-separated and evidence never mints authority. |

## Exact Shared-Target Ownership and Serialization

The registry intentionally retains exact promotion targets so runtime
exact-or-directory-prefix overlap detection can serialize every physical
collision. The table below covers the creation-baseline overlaps plus the exact
serialized targets added by the brokered no-PR revision. “Owns” means semantic authority for the named
surface; contributors may change only the named row, symbol, registration, or
specialization. Dependency gates order declared predecessors. Unordered peers
must acquire the same exact-path integration lock and run in a single
integration lane; they never edit the target concurrently.

| Exact shared target(s) | Semantic owner and bounded contribution | Deterministic serialization |
| --- | --- | --- |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-agent-node-model-call-contract.sh` | RP-11 owns generic model-call validation; RP-13 may add only the MissionChild mapping assertion. | RP-11, then RP-13. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-workflow-statechart-harness.sh` | RP-11 owns generic Harness validation; RP-13 may add only child depth, mapping, and retirement assertions. | RP-11, then RP-13. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh` | RP-00 owns containment baseline checks; RP-01 owns final authority semantics; RP-04 may register only broker-specific coverage assertions. | RP-00, RP-01, then RP-04. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh` | RP-01 owns the global dispatcher after RP-00 containment; RP-04, RP-11, and RP-13 may add only calls to their dedicated validators. | Dependency order; RP-04 and RP-11 peer registrations serialize on this path; RP-13 follows RP-11. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh` | RP-00 owns the data-driven inventory validator; RP-04 may add only broker-row assertions. | RP-00, then RP-04. |
| `.octon/framework/cognition/_meta/architecture/contract-registry.yml` | RP-10 owns project/profile rows, RP-11 Harness/adapter rows, and RP-13 MissionChild rows. | RP-10, RP-11, then RP-13. |
| `.octon/framework/constitution/contracts/adapters/family.yml` | RP-11 owns generic adapter entries; RP-13 owns only the child-provider mapping entry. | RP-11, then RP-13. |
| `.octon/framework/constitution/contracts/adapters/host-adapter-v1.schema.json` | RP-11 owns the generic host schema; RP-02 and RP-04 may add only isolation and broker specialization bindings accepted at their design gates. | RP-02 and RP-04 peer edits serialize; RP-11 performs the final generic-schema integration. |
| `.octon/framework/constitution/contracts/registry.yml` | Exact rows are owned by RP-03 store, RP-07 evidence, RP-08 recovery, RP-10 projects, RP-11 Harness, and RP-13 children. | Exact-path lock plus dependency order; unordered row owners integrate one at a time. |
| `.octon/framework/constitution/contracts/retention/evidence-store-v1.schema.json`; `.octon/framework/constitution/contracts/retention/family.yml`; `.octon/framework/engine/runtime/spec/evidence-store-v1.md` | RP-07 owns evidence semantics; RP-03 owns only storage, transaction, and capacity substrate bindings. | RP-03, then RP-07. |
| `.octon/framework/constitution/contracts/runtime/family.yml` | Exact entries: RP-03 store, RP-04 broker, RP-08 recovery, RP-10 projects, RP-11 Harness, RP-13 children. | Dependency order; RP-03/RP-10 and RP-04/RP-11 peer rows serialize on the exact path. |
| `.octon/framework/constitution/contracts/runtime/task-specific-execution-harness-v1.schema.json`; `.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.md`; `.octon/framework/engine/runtime/spec/task-specific-execution-harness-v1.schema.json` | RP-11 owns the canonical Harness contract; RP-02 owns only candidate-isolation binding fields and RP-13 only child narrowing fields. | RP-02, RP-11, then RP-13; final parity check covers both schema copies. |
| `.octon/framework/engine/runtime/crates/Cargo.lock` | RP-03 and RP-04 own only their accepted dependency closures. | RP-03, then RP-04, with one lockfile regeneration. |
| `.octon/framework/engine/runtime/crates/Cargo.toml` | Exact member/dependency rows belong to RP-03 store, RP-04 broker, RP-07 evidence, and RP-08 reconciler. | RP-03, RP-04, RP-07, then RP-08. |
| `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/effects.rs`; `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs`; `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/records.rs` | RP-01 owns authority semantics; RP-03 may add only calls into its separately owned persistence adapter, never redefine a decision. | RP-01 freezes the interface; RP-03 integrates afterward. |
| `.octon/framework/engine/runtime/crates/kernel/src/commands/mission.rs` | RP-10 owns project/inbox symbols, RP-08 recovery/status symbols, and RP-13 child symbols. | RP-08 and RP-10 peer symbol edits serialize; RP-13 follows RP-10 through RP-11 and integrates last. |
| `.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs` | RP-04 owns broker registration; RP-06 owns verifier/publication registration. | RP-04, then RP-06. |
| `.octon/framework/engine/runtime/crates/kernel/src/main.rs` | RP-04 owns broker CLI entries, RP-10 project entries, and RP-13 child entries. | RP-04/RP-10 peer entries serialize; RP-13 integrates after RP-10. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/adapter.rs`; `.octon/framework/engine/runtime/crates/lifecycle_executor/src/auto.rs`; `.octon/framework/engine/runtime/crates/lifecycle_executor/src/claude.rs`; `.octon/framework/engine/runtime/crates/lifecycle_executor/src/codex.rs`; `.octon/framework/engine/runtime/crates/lifecycle_executor/src/request.rs` | In `codex.rs`, RP-01 owns only exact guard invocation/bypass removal; RP-02 owns candidate-isolation hooks; RP-11 owns the later generic adapter boundary. Other listed files remain partitioned between RP-02 and RP-11. | `codex.rs`: RP-01, RP-02, then RP-11. Other listed files: RP-02, then RP-11. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/authorization.rs` | RP-01 owns guard semantics; RP-11 owns only exact Harness-digest binding at the frozen guard API. | RP-01, then RP-11. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/src/lib.rs` | Exact exports: RP-02 isolation, RP-11 adapter, RP-13 child. | RP-02, RP-11, then RP-13. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs` | RP-02 owns candidate-isolation positive cases; RP-11 owns generic adapter conformance. | RP-02 cases land first; RP-11 integrates the final suite. |
| `.octon/framework/engine/runtime/crates/runtime_resolver/src/handles.rs`; `.octon/framework/engine/runtime/crates/runtime_resolver/src/lib.rs` | RP-11 owns the generic handle interface; RP-12 owns only extension-generation symbols. | RP-11, then RP-12. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md`; `.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.schema.json` | RP-00 owns the containment baseline; RP-01 owns the final authority contract. | RP-00, then RP-01. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml` | Exact inventory rows: RP-00 baseline, RP-01 authority, RP-04 broker, RP-05 Git, RP-06 verifier/publication. | RP-00, RP-01, RP-04, RP-05, then RP-06. |
| `.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | RP-01 owns the frozen authorization specification; RP-04 may add only its broker binding reference. | RP-01, then RP-04. |
| `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml` | Exact rows: RP-00 baseline, RP-04 broker, RP-05 Git, RP-06 verifier/publication. | RP-00, RP-04, RP-05, then RP-06. |
| `.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | RP-08 owns generic recovery lifecycle semantics; RP-13 may add only MissionChild references whose semantics remain in its dedicated contract. | RP-08, then RP-13. |
| `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml` | RP-05 owns the sanitized Git primitive; RP-06 owns deterministic publication routing. | RP-05, then RP-06. |
| `.octon/framework/product/contracts/default-work-unit.yml`; `.octon/framework/product/contracts/default-work-unit.md` | RP-00 owns containment removal/disablement of current routes; RP-06 later owns only the final publication-route projection that consumes canonical `change-publication.yml`. No duplicated policy source survives cutover. | RP-00, then RP-06. |
| `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land.sh`; `.octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh`; `.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh` | RP-00 owns only hard-disable/retirement containment; RP-05 later owns closed ref primitives and RP-08/RP-06 own cleanup/route semantics. | RP-00, then RP-05/RP-06/RP-08 through declared dependencies. |
| `.octon/instance/governance/policies/mission-autonomy.yml` | RP-08 owns production Class-B policy; RP-04 may add only the scratch broker-disabled posture. | RP-04, then RP-08. |

At child acceptance, implementation review must either prove each bounded
contribution above or remove that child’s target claim. Broad consumer-only
edits are prohibited. Registry write-scope coverage and duplicate-path
enumeration are regenerated after any target change.
