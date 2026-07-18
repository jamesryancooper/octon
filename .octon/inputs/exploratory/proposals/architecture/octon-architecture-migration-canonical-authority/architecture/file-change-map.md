# File Change Map

| Durable surface | Ownership | Change class |
| --- | --- | --- |
| `authority_engine/src/implementation/{api,execution,effects,policy,records}.rs` | RP-01 semantic owner; `runtime_state.rs` excluded for RP-03 | versioned semantic interface and receipts |
| `policy_engine/**`, runtime policy config/spec | RP-01 | one installed policy/evaluator identity |
| `lifecycle_executor/src/authorization.rs` | RP-01 | `CandidateLaunchDescriptor` and `consume_candidate_launch_guard` semantics |
| `kernel/src/pipeline.rs::{run_codex,run_claude,run_with_stdin}` | RP-01 guard-invocation owner; command construction and pipeline semantics remain unchanged | final consuming guard immediately before spawn |
| `kernel/src/workflow.rs::{WorkflowExecutor::execute_stage_codex,WorkflowExecutor::execute_stage_claude,run_command_with_stdin}` | RP-01 guard-invocation owner; workflow and stage semantics remain unchanged | final consuming guard immediately before spawn |
| `lifecycle_executor/src/codex.rs::run_with_timeout` | RP-01 guard invocation, then RP-02 isolation hook, then RP-11 adapter integration | final consuming guard immediately before Codex/Claude spawn |
| `lifecycle_executor/src/workflow_leaf.rs::run_workflow_command` | RP-01 guard-invocation owner; admitted workflow resolution remains unchanged | final consuming guard immediately before leaf-runtime spawn |
| authority contracts and boundary specs | RP-01 entry ownership in shared registries | typed grant, revocation, and scope rules |
| `validate-authorization-boundary-coverage.sh` and three named assurance tests | RP-01 | closed candidate-spawn inventory, raw-spawn negative controls, dynamic guarded-launch, concurrency, and fault proof |

No `.github/**`, provider setting, credential, generated projection, or proposal
path is a durable RP-01 implementation target.

The existing grant/scope contract targets carry the typed publication tuple;
no new route-policy, verifier, broker, provider, or Git target is added.
