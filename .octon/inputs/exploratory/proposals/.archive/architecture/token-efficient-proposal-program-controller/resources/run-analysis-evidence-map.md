# Run Analysis Evidence Map

| Evidence Item | Repository Path | Relevance |
|---|---|---|
| Prompt renderer expands bound inputs | `/.octon/framework/engine/runtime/crates/lifecycle_executor/src/prompt_bundle.rs` | render_extension_prompt adds Bound Inputs and all bundle assets. |
| Prompt resolver collects all assets | `/.octon/framework/engine/runtime/crates/lifecycle_executor/src/generated.rs` | collect_assets loads prompt_assets, reference_assets, and shared_reference_assets. |
| Completed run checkpoint | `/.octon/state/control/execution/runs/lifecycle-proposal-program-1780379179921-9bb1eb22/program-lifecycle-checkpoint.yml` | Records all nine child states archived/completed, dependency gates, write scopes, aggregate blocker digest, and final verdict. |
| Completed run events | `/.octon/state/control/execution/runs/lifecycle-proposal-program-1780379179921-9bb1eb22/program-events.ndjson` | Records run-started, plan-created no-dispatch, and aggregate-terminal-blockers events. |
| Parent terminal routing program | `/.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening/proposal.yml` | Defines the prior nine-child gated-parallel program and authority boundary. |
| Child packet index pattern | `/.octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening/resources/child-packet-index.yml` | Shows child registry structure, dependencies, phases, groups, source lineage, and write scopes. |
| Context pack builder inclusion modes | `/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md` | Already supports full, excerpt, summary, handle-only, digest-only, omitted, retained model-visible context hash, source manifests, omissions, invalidation. |
| Run lifecycle authorization boundary | `/.octon/framework/engine/runtime/spec/run-lifecycle-v1.md` | Requires context-pack receipt before authorization and fail-closed transition behavior. |

## Findings Coverage

- TE-001 is addressed by prompt-pack handles and compiled instruction capsules.
- TE-002 is addressed by evidence indexes, raw-log summaries, and failing-slice manifests.
- TE-003 is addressed by planner-state and program-context capsules.
- TE-004 is addressed by validator result manifests and generated freshness handles.
- TE-005 is addressed by blocker-ledger and recovery delta summaries.
- TE-006 is addressed by closeout capsules and concise closeout projections.
- TE-007 is addressed by generated/read-model freshness handles and compact indices.
- TE-008 is addressed by lifecycle executor context-pack integration.
