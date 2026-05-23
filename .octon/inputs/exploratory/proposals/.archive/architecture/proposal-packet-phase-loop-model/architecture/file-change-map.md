# File Change Map

## Source-Authored Or Publication-Input Targets

| Path | Class | Later Change Intent | Authority Note |
| --- | --- | --- | --- |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml` | authored publication input | Add explicit proposal packet phase-loop declarations and bind phases to current routes, receipts, gates, and loops. | Input source only; runtime discovery happens through publication. |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle-model.md` | authored publication input | Document phase-loop model, stop classes, loop bounds, checkpoint expectations, and non-status phase semantics. | Non-authoritative until published into durable docs or effective projection. |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/routing-guide.md` | authored publication input | Explain operator routing through phase-loop handoffs and execute-routes mode. | Does not grant authority. |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/` | authored publication input | Update user-facing command docs for phase-loop behavior and generated projection boundaries. | Command docs are extension inputs. |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/` | authored publication input | Update skills to state phase-loop gates, review freshness, and no self-authorization. | Skill prompts remain operational aids. |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/` | authored publication input | Align prompt bundles to phase-loop receipt, gate, and closeout expectations. | Prompts cannot become authority. |
| `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/` | authored publication input | Add phase-loop validation scenarios and extension-local tests. | Validation input only until run. |
| `.octon/framework/product/features/lifecycle-autopilot.md` | source-authored feature note | Describe phase-loop substrate and runner/executor boundary. | Product feature documentation, subordinate to constitutional authority. |
| `.octon/framework/product/features/catalog.yml` | source-authored catalog | Register durable refs, runtime surfaces, generated handles, and validation refs if new surfaces are added. | Product catalog for discovery and alignment. |
| `.octon/framework/product/contracts/change-closeout-state-machine.md` | source-authored product contract | Clarify alignment between Change closeout phase-loop semantics and generic lifecycle phase-loop substrate without changing Change route authority. | Does not replace default work-unit route selection. |
| `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json` | source-authored schema | Add generic phase-loop schema fields if needed. | Runtime spec surface. |
| `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/lifecycle-run-event.schema.json` | source-authored schema | Add phase and loop event categories and fields if needed. | Runtime spec surface. |
| `.octon/framework/engine/runtime/spec/lifecycle-route-execution-request-v1.schema.json` | source-authored schema | Optionally include `phase_id` as executor request context only. | Context field only; never route authority. |
| `.octon/framework/engine/runtime/spec/lifecycle-route-execution-result-v1.schema.json` | source-authored schema | Optionally echo `phase_id` in execution result context for observation. | Observation context only; executor still cannot select phase. |
| `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs` | source-authored runtime code | Parse and evaluate phase-loop declarations; record phase checkpoint and event metadata. | Runtime implementation. |
| `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_driver.rs` | source-authored runtime code | Preserve phase-loop budgets across plan-execute-replan dispatches. | Runtime implementation. |
| `.octon/framework/engine/runtime/crates/lifecycle_executor/` | source-authored runtime code | Confirm executor remains route-invocation only; update request or result if phase metadata is needed for observation. | Executor must not own phase planning or authorization. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-contracts.sh` | source-authored validator | Validate phase-loop references, no status widening, and fail-closed declarations. | Validator surface. |
| `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh` | source-authored tests | Cover phase planning, loop bounds, checkpoint resume, event-log convergence, and cancellation. | Validation evidence. |
| `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-executor-adapter.sh` | source-authored tests | Prove executor cannot self-authorize or bypass runner-selected phase gates. | Validation evidence. |
| `.octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-v1-acceptance.sh` | source-authored tests | Add end-to-end proposal phase-loop acceptance scenarios. | Validation evidence. |

## Generated Projection Targets

| Path | Later Handling | Authority Note |
| --- | --- | --- |
| `.octon/generated/effective/extensions/catalog.effective.yml` | Refresh after source-authored extension changes land. | Generated discovery handle only. |
| `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/lifecycle.contract.yml` | Refresh after source lifecycle contract changes land. | Generated projection only. |
| `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/lifecycles/proposal-program.contract.yml` | Refresh only if publication lock or shared catalog changes require it. | Generated projection only. |
| `.octon/generated/proposals/registry.yml` | Refresh only as normal proposal registry publication after packet creation or closeout if explicitly routed. | Discovery-only proposal registry. |

## Host Projection Targets

| Path | Later Handling | Authority Note |
| --- | --- | --- |
| `.codex/skills/octon-proposal-lifecycle*/SKILL.md` | Refresh from source extension skill inputs if the implementation changes projected proposal lifecycle skills. | Host projection only; not source authority and not a promotion target for this octon-internal packet. |

Generated files are not source authority and must not be hand-edited to create
the target model.
