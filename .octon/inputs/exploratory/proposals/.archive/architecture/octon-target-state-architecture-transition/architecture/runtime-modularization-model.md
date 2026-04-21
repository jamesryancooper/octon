# Runtime Modularization Model

## Current posture

The kernel currently exposes a broad command surface: information, service management, tool invocation, validation, stdio server, Studio launch, service scaffolding, run lifecycle commands, workflow compatibility commands, and orchestration inspection. This breadth is directionally correct for a governed runtime, but target-state Octon needs lower coupling between CLI routing, request construction, side-effect classification, output rendering, and authorization behavior.

## Target module layout

```text
.octon/framework/engine/runtime/crates/kernel/src/
├── main.rs                       # CLI parse and top-level dispatch only
├── commands/
│   ├── info.rs
│   ├── services.rs
│   ├── tool.rs
│   ├── validate.rs
│   ├── studio.rs
│   ├── run.rs
│   ├── workflow_compat.rs
│   └── orchestration.rs
├── request_builders/
│   ├── service_invocation.rs
│   ├── executor_launch.rs
│   ├── workflow_stage.rs
│   ├── publication.rs
│   └── repo_mutation.rs
├── renderers/
│   ├── json.rs
│   ├── markdown.rs
│   └── diagnostics.rs
└── side_effects/
    ├── inventory.rs
    ├── classify.rs
    └── coverage.rs
```

```text
.octon/framework/engine/runtime/crates/authority_engine/src/
├── implementation/
│   └── execution.rs              # Public authorize_execution orchestration only
└── phases/
    ├── request_normalization.rs
    ├── active_intent.rs
    ├── environment.rs
    ├── executor_profile.rs
    ├── write_scope.rs
    ├── run_lifecycle.rs
    ├── run_contract.rs
    ├── ownership.rs
    ├── support_posture.rs
    ├── rollback.rs
    ├── egress.rs
    ├── budget.rs
    ├── approvals.rs
    ├── decision_artifact.rs
    ├── grant_bundle.rs
    └── evidence_linkage.rs
```

## Design rules

- `main.rs` must not contain material side-effect implementation.
- Request builders must emit side-effect class metadata.
- Authorization phases must emit machine-readable phase results.
- Denials must emit stable reason codes from fail-closed obligations.
- Legacy workflow compatibility remains in `workflow_compat.rs` and must redirect to run-first semantics or fail closed.

## Why modularize

This is not cosmetic. Runtime modularization improves:

- auditability of the execution boundary;
- test isolation;
- reason-code stability;
- ability to prove coverage;
- maintainability under new adapters;
- change containment for future productization.
