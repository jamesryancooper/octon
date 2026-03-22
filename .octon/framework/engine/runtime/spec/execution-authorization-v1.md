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

## Required Guarantees

- No material side effect may occur before a valid `GrantBundle` exists.
- Protected execution must fail closed unless the effective mode is
  `hard-enforce`.
- Denials must emit machine-readable reason codes.
- Receipt emission is mandatory for every material execution attempt.
- Executor launches must use named executor profiles and wrapper-enforced flag
  filtering.

## Related Contracts

- `execution-request-v1.schema.json`
- `execution-grant-v1.schema.json`
- `execution-receipt-v1.schema.json`
- `executor-profile-v1.schema.json`
- `policy-interface-v1.md`
- `policy-receipt-v1.schema.json`
