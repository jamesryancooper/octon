# Execution Authorization v1

This contract defines the engine-owned runtime boundary for material execution.

## Mandatory Boundary

All material execution must pass through:

```rust
authorize_execution(request: ExecutionRequest) -> GrantBundle
```

`GrantBundle` is the engine-owned authorization decision product. It is not by
itself a consumable side-effect capability. Material APIs must consume
`AuthorizedEffect<T>` values issued from the active allow grant and verify them
into `VerifiedEffect<T>` guards before mutation.

Material paths include service invocation, workflow-stage execution, executor
launch, repo mutation, publication, protected CI checks, and any other path
that can produce durable side effects.

Wave 2 normalization additionally requires runtime to retain canonical
authority artifacts for approvals, exceptions, revocations, decision
artifacts, and grant bundles under `state/control/execution/**` and
`state/evidence/control/execution/**`.

## Required Guarantees

- No material side effect may occur before a valid `GrantBundle` exists.
- No material side effect may occur unless the callee receives a valid typed
  `AuthorizedEffect<T>` derived from the current allow grant.
- No material side effect may occur unless that token verifies against the
  canonical token record, run lifecycle state, support posture, and capability
  envelope and yields `VerifiedEffect<T>`.
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
- Token issuance, verification, consumption, rejection, expiry, and revocation
  must materialize in canonical control/evidence roots and the Run Journal.
- Missing token record, digest drift, support-tuple mismatch, capability-pack
  mismatch, expiry, revocation, scope mismatch, or missing receipt/journal
  persistence must fail closed.
- Labels, comments, checks, and similar host affordances are projections only;
  policy evaluation ignores them whenever they disagree with canonical
  approval artifacts.
- Plan leaves may prepare authorization requests, but they never become grants.
  MissionPlan, PlanNode, and PlanCompileReceipt artifacts are compiler evidence
  or control lineage only. Material effects still require a valid
  `GrantBundle`, typed `AuthorizedEffect<T>`, verified `VerifiedEffect<T>`,
  retained receipt, and Run Journal coverage.

## Related Contracts

- `execution-request-v3.schema.json`
- `execution-grant-v1.schema.json`
- `execution-receipt-v3.schema.json`
- `authorized-effect-token-v1.md`
- `authorized-effect-token-v2.schema.json`
- `authorized-effect-token-consumption-v1.schema.json`
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
