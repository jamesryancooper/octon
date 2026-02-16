# Plan — Native Plan Synthesis and DAG Validation

Plan transforms goals and optional step candidates into a canonical `plan`
object with dependency validation and deterministic ordering.

## Responsibilities

- Normalize goal + constraints into a stable plan payload.
- Validate step identifiers and dependency references.
- Detect cyclic graphs and fail closed.
- Emit canonical topological order in `plan.order`.

## Core Guarantees

- Deterministic output for identical inputs.
- Fail-closed runtime errors for invalid dependency graphs.
- No external runtime dependency required.

## Input and Output Contracts

- Input schema: `schema/input.schema.json`
- Output schema: `schema/output.schema.json`
- Invariants: `contracts/invariants.md`
- Errors: `contracts/errors.yml`

## Example

```bash
cat <<'JSON' | .harmony/capabilities/services/planning/plan/impl/plan.sh
{"goal":"Refresh docs","steps":[{"id":"inventory"},{"id":"update","depends_on":["inventory"]}]}
JSON
```
