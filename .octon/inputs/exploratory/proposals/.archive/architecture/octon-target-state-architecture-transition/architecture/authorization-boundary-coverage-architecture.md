# Authorization-Boundary Coverage Architecture

## Problem

The live architecture declares `authorize_execution(request: ExecutionRequest) -> GrantBundle` as the mandatory boundary for material execution. The runtime imports and uses the authorization engine, and the kernel exposes run-first lifecycle commands. The missing target-state property is not the existence of the boundary; it is machine-checkable coverage proving that every material side-effect path is mediated.

## Target contract

Introduce a material side-effect inventory and authorization coverage map.

### Material side-effect inventory

A durable framework spec declares every path class capable of durable side effects:

```yaml
schema_version: material-side-effect-inventory-v1
classes:
  - id: repo-mutation
    roots: ["."]
    examples: ["write source file", "delete file", "git apply"]
    required_boundary: authorize_execution
  - id: control-mutation
    roots: [".octon/state/control/**"]
    required_boundary: authorize_execution
  - id: evidence-mutation
    roots: [".octon/state/evidence/**"]
    required_boundary: authorize_execution_or_evidence_writer
  - id: generated-effective-publication
    roots: [".octon/generated/effective/**"]
    required_boundary: publication_authorization
```

### Coverage map

Each material path declares:

- command or service entrypoint;
- side-effect class;
- request builder;
- authorization call site;
- grant artifact path;
- receipt artifact path;
- denial reason code;
- tests covering allow, stage-only, deny, and stale/generated-negative cases.

## Required validators

- `validate-material-side-effect-inventory.sh`
- `validate-authorization-boundary-coverage.sh`
- `test-authorization-boundary-coverage.sh`
- `test-generated-as-authority-denial.sh`
- `test-host-projection-authority-denial.sh`

## Fail-closed behavior

Any material path absent from the inventory, missing a coverage mapping, missing an authorization call site, or missing retained receipts must fail closed before promotion.

## Acceptance posture

Target-state acceptance requires a coverage report under `state/evidence/validation/architecture-target-state-transition/authorization-boundary-coverage/` that lists every material path and its proof status.
