# Execution

Run plans through durable agents and native flow runtime.

## Native-First Portability Policy (Normative)

The Execution domain is tech-stack-agnostic and OS-agnostic by default.
Core execution behavior must run inside Octon harness constraints without
requiring Python.

Policy rules:

1. `agent` and `flow` are core Execution services and must have native harness execution paths.
2. Flow defaults to native runtime execution; external runtimes (including LangGraph) are optional adapters.
3. Agent consumes planning outputs (`plan.json`) and never requires a separate per-agent runtime.
4. Provider/runtime-specific terms are restricted to adapter contracts and compatibility docs.

## Services

- [Agent](./agent/guide.md)
- [Flow](./flow/guide.md)

For canonical ownership and integration details, see:

- `./service-roles.md`
- `../planning/README.md`

## Validation

- `bash .octon/capabilities/runtime/services/execution/_ops/scripts/validate-execution-fixtures.sh`
- `bash .octon/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh --mode services-core`
