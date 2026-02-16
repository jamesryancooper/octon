# Agent — Native Plan Execution MVP

Agent executes plan contracts with durable checkpoint files, deterministic run
identifiers, and explicit human-in-the-loop (HITL) gates.

## Responsibilities

- Execute plan runs in native harness mode.
- Persist checkpoints under `.harmony/runtime/_ops/state/agent/checkpoints/`.
- Persist run records under `.harmony/runtime/_ops/state/agent/runs/`.
- Support `resume=true` with checkpoint restoration.
- Support HITL pause/resume using `hitl.required` and `hitl.approved`.

## Core Guarantees

- No Python runtime dependency is required.
- Missing checkpoints fail closed.
- Resume transitions are explicit and auditable.

## Input and Output Contracts

- Input schema: `schema/input.schema.json`
- Output schema: `schema/output.schema.json`
- Invariants: `contracts/invariants.md`
- Errors: `contracts/errors.yml`

## Example (execute)

```bash
cat <<'JSON' | .harmony/capabilities/services/execution/agent/impl/agent.sh
{"planPath":"plan.json","resume":false,"memoize":true}
JSON
```

## Example (resume with approval)

```bash
cat <<'JSON' | .harmony/capabilities/services/execution/agent/impl/agent.sh
{"planPath":"plan.json","runId":"run-123","resume":true,"hitl":{"approved":true}}
JSON
```
