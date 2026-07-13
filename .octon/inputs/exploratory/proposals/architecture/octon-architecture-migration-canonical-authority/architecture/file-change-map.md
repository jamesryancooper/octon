# File Change Map

| Durable surface | Ownership | Change class |
| --- | --- | --- |
| `authority_engine/src/implementation/{api,execution,effects,policy,records}.rs` | RP-01 semantic owner; `runtime_state.rs` excluded for RP-03 | versioned semantic interface and receipts |
| `policy_engine/**`, runtime policy config/spec | RP-01 | one installed policy/evaluator identity |
| `lifecycle_executor/src/authorization.rs` | RP-01 | exact guard API |
| lifecycle/kernel launch call sites | shared integration lane; RP-01 owns guard invocation only | bypass removal and dominance |
| authority contracts and boundary specs | RP-01 entry ownership in shared registries | typed grant, revocation, and scope rules |
| assurance validators/fixtures | RP-01 | static, adversarial, concurrency, and fault proof |

No `.github/**`, provider setting, credential, generated projection, or proposal
path is a durable RP-01 implementation target.
