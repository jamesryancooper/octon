# Authorization Coverage Map

This map is a derived summary of the runtime authorization boundary. It is not
an authority source.

## Canonical Boundary

- Boundary contract: `/.octon/framework/engine/runtime/spec/execution-authorization-v1.md`
- Coverage contract: `/.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md`
- Inventory schema: `/.octon/framework/engine/runtime/spec/material-side-effect-inventory-v1.schema.json`
- Coverage schema: `/.octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.schema.json`

## Runtime Surfaces

- Kernel dispatch and command routing: `framework/engine/runtime/crates/kernel/src/**`
- Authority orchestration and phases: `framework/engine/runtime/crates/authority_engine/src/**`
- Coverage evidence: `state/evidence/validation/architecture-target-state-transition/authorization-boundary/coverage.yml`

## Negative Controls

- Generated-as-authority denial
- Host-projection-as-authority denial
- Unmediated side-effect denial
- Unsupported support-claim denial
- Stale generated/effective denial
