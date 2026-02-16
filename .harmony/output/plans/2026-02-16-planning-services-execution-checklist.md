# Planning+Execution Services Checklist (Ordered, Gate-Driven)

Date: 2026-02-16  
Owner: architect  
Scope: `.harmony/capabilities/services/{planning,execution}/**` + required runtime/platform updates

## Rules

1. Execute phases strictly in numeric order.
2. Do not start phase `N+1` until phase `N` gate passes.
3. If a phase gate fails, resolve failures in the same phase.
4. Core Planning+Execution services must remain tech-stack-agnostic and OS-agnostic.
5. Python is not allowed as a required runtime dependency for core Planning services.
6. External runtimes (including LangGraph) are optional adapters only.

## Phase Tracker

### Phase 0: Contract Lock and ADR

Status: `completed`  
Deliverables:
- `/.harmony/cognition/decisions/013-planning-services-native-first-no-python.md`
- `/.harmony/capabilities/services/planning/README.md` (native-first update)
- `/.harmony/capabilities/services/execution/service-roles.md` (native-first update)

Gate:
- ADR created and ready for review.
  - Planning/execution docs explicitly state:
  - native harness execution is mandatory
  - external runtime adapters are optional
  - Python is not required in core paths

### Phase 1: Register Spec/Plan/Agent/Playbook as First-Class Services

Status: `completed`  
Deliverables:
- `/.harmony/capabilities/services/planning/spec/{SERVICE.md,schema/,rules/,fixtures/,contracts/,compatibility.yml,impl/generated.manifest.json}`
- `/.harmony/capabilities/services/planning/plan/{SERVICE.md,schema/,rules/,fixtures/,contracts/,compatibility.yml,impl/generated.manifest.json}`
- `/.harmony/capabilities/services/execution/agent/{SERVICE.md,schema/,rules/,fixtures/,contracts/,compatibility.yml,impl/generated.manifest.json}`
- `/.harmony/capabilities/services/planning/playbook/{SERVICE.md,schema/,rules/,fixtures/,contracts/,compatibility.yml,impl/generated.manifest.json}`
- `/.harmony/capabilities/services/{manifest.yml,registry.yml,capabilities.yml}` updated

Gate command:

```bash
bash .harmony/capabilities/services/_ops/scripts/validate-services.sh
```

### Phase 2: Runtime HTTP Capability (Capability-Gated)

Status: `completed`  
Deliverables:
- `/.harmony/runtime/wit/world.wit` updated with HTTP import
- `/.harmony/runtime/crates/wasm_host/src/host_api.rs` HTTP host implementation
- `/.harmony/runtime/config/policy.yml` capability policy updates
- runtime tests for deny-by-default + timeout/error behavior

Gate commands:

```bash
cd .harmony/runtime/crates
cargo test -p harmony_core -p harmony_wasm_host -p harmony_kernel
cargo run -p harmony_kernel -- validate
```

### Phase 3: Convert Flow to Rust/WASM Runtime Service

Status: `completed`  
Deliverables:
- `/.harmony/capabilities/services/execution/flow/rust/**`
- `/.harmony/capabilities/services/execution/flow/service.json`
- `/.harmony/capabilities/services/execution/flow/service.wasm`
- `/.harmony/capabilities/services/{manifest.runtime.yml,registry.runtime.yml}` updated

Gate commands:

```bash
cd .harmony/runtime/crates
cargo run -p harmony_kernel -- service build execution flow
cargo run -p harmony_kernel -- validate
```

### Phase 4: Native Flow Engine as Default Runtime

Status: `completed`  
Deliverables:
- Native flow execution path supports workflow manifests and canonical prompts without external runtimes.
- Deterministic run records and fail-closed errors are emitted.

Gate:
- `packages/workflows/architecture_assessment/config.flow.json` runs via native adapter.
- `packages/workflows/docs_glossary/config.flow.json` runs via native adapter.

### Phase 5: Adapter Layer for Optional External Runtimes

Status: `completed`  
Deliverables:
- `/.harmony/capabilities/services/execution/flow/adapters/registry.yml`
- `/.harmony/capabilities/services/execution/flow/adapters/native-harmony/**`
- `/.harmony/capabilities/services/execution/flow/adapters/langgraph-http/**`
- `/.harmony/capabilities/services/execution/flow/impl/validate-adapters.sh`

Gate:
- `native-harmony` is default.
- `langgraph-http` is optional and validated.

### Phase 6: Remove Python-Required Defaults from Flow Configs

Status: `completed`  
Deliverables:
- `packages/workflows/architecture_assessment/config.flow.json` updated
- `packages/workflows/docs_glossary/config.flow.json` updated

Gate command:

```bash
rg -n "pythonCommand|agents\\.runner\\.runtime\\.server|\\.venv/bin/python" \
  packages/workflows .harmony/capabilities/services/planning .harmony/capabilities/services/execution
```

Expected result:
- No Python-required defaults in core config paths.

### Phase 7: Implement In-House Spec Service (No Speckit Runtime Dependency)

Status: `completed`  
Deliverables:
- `/.harmony/capabilities/services/planning/spec/impl/**` implements native ops and contracts.

Gate:
- Spec fixtures pass.
- Deterministic outputs match schema/contracts.

### Phase 8: Implement Playbook Service

Status: `completed`  
Deliverables:
- `/.harmony/capabilities/services/planning/playbook/impl/**`

Gate:
- Playbook fixtures pass with deterministic output.

### Phase 9: Implement Plan Service

Status: `completed`  
Deliverables:
- `/.harmony/capabilities/services/planning/plan/impl/**`
- Emits canonical `plan.json` with DAG validation.

Gate:
- Positive fixture outputs valid plan.
- Negative fixture rejects cyclic/invalid plan.

### Phase 10: Implement Agent Service MVP + Final Hardening

Status: `completed`  
Deliverables:
- `/.harmony/capabilities/services/execution/agent/impl/**`
- checkpoint/resume/HITL support
- command/docs alignment

Gate commands:

```bash
bash .harmony/capabilities/services/_ops/scripts/validate-services.sh
bash .harmony/capabilities/services/_ops/scripts/validate-service-independence.sh --mode all
cd .harmony/runtime/crates
cargo test --workspace
cargo run -p harmony_kernel -- validate
```

## Progress Log

- 2026-02-16: Tracker created. Phase 0 started.
- 2026-02-16: Added ADR-013 and updated Planning domain docs for native-first no-Python core policy.
- 2026-02-16: Completed Phase 1 scaffolding and registration for spec/plan/playbook/agent; validate-services gate passed.
- 2026-02-16: Completed Phase 2 by adding capability-gated runtime HTTP host import/implementation with deny-by-default tests; runtime gate commands passed.
- 2026-02-16: Completed Phase 3 by converting `execution/flow` to a Rust/WASM runtime service, adding `service.json` and building `service.wasm`; runtime tier discovery updated and validated.
- 2026-02-16: Completed Phase 4 by implementing native-harmony flow execution defaults with deterministic run ids/run records and validating both workflow configs through the kernel.
- 2026-02-16: Completed Phase 5 by adding flow adapter registry (`native-harmony` default + optional `langgraph-http`) and adapter validation script with passing gate.
- 2026-02-16: Completed Phase 6 by removing Python-required defaults from workflow configs and resolving all policy grep matches in Planning core paths.
- 2026-02-16: Completed Phases 7-10 by implementing native `spec`, `playbook`, `plan`, and `agent` services (including DAG validation and checkpoint/resume/HITL) and adding deterministic fixture validation script.
- 2026-02-16: Final hardening gates passed: `validate-services`, `validate-service-independence --mode all`, `cargo test --workspace`, and `harmony validate`.
- 2026-02-16: Migrated `agent` and `flow` services from Planning to Execution domain with updated manifests, runtime policy entries, docs, and fixture validation split (`validate-planning-fixtures` + `validate-execution-fixtures`).
