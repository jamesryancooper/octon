# Execution Authorization v1

This contract defines the engine-owned runtime boundary for material execution.

## Mandatory Boundary

All material execution must pass through:

```rust
authorize_execution(request: ExecutionRequest) -> GrantBundle
```

Material paths include service invocation, workflow-stage execution, executor
launch, repo mutation, publication, protected CI checks, and any other path
that can produce durable side effects.

Wave 2 normalization additionally requires runtime to retain canonical
authority artifacts for approvals, exceptions, revocations, decision
artifacts, and grant bundles under `state/control/execution/**` and
`state/evidence/control/execution/**`.

## Required Guarantees

- No material side effect may occur before a valid `GrantBundle` exists.
- The authorization boundary binds the canonical retained run root under
  `state/evidence/runs/<run_id>/` before retained execution artifacts are
  emitted.
- Protected execution must fail closed unless the effective mode is
  `hard-enforce`.
- Denials must emit machine-readable reason codes.
- Receipt emission is mandatory for every material execution attempt.
- Executor launches must use named executor profiles and wrapper-enforced flag
  filtering.
- Outbound HTTP and model-backed execution must satisfy repo-owned network
  egress and execution-budget policy before the material path proceeds.
- Ownership resolution, support-tier routing, reversibility posture, budget
  posture, and egress posture must participate in authority routing before a
  grant is emitted.
- Context-pack provenance, risk/materiality classification, and rollback-plan
  posture must participate in authority routing whenever the execution path is
  consequential or boundary-sensitive.
- Governed capability-pack admission must agree with the published support
  matrix before a grant is emitted.
- Labels, comments, checks, and similar host affordances are projections only;
  policy evaluation ignores them whenever they disagree with canonical
  approval artifacts.

## Related Contracts

- `execution-request-v3.schema.json`
- `execution-grant-v1.schema.json`
- `execution-receipt-v3.schema.json`
- `authorization-phase-result-v1.schema.json`
- `runtime-event-v1.schema.json`
- `/.octon/framework/constitution/contracts/authority/risk-materiality-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/rollback-plan-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/browser-ui-execution-record-v1.schema.json`
- `/.octon/framework/constitution/contracts/runtime/api-egress-record-v1.schema.json`
- `executor-profile-v1.schema.json`
- `policy-interface-v1.md`
- `policy-receipt-v2.schema.json`
- `policy-digest-v2.md`

Phase results are retained under the canonical run receipts root at
`state/evidence/runs/<run_id>/receipts/authorization-phases/**` and are
mirrored into the run evidence trail alongside the decision, grant, request,
and execution receipt artifacts.
