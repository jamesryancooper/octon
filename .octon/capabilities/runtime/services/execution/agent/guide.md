# Agent — Native Plan Execution MVP

Agent executes plan contracts with durable checkpoint files, deterministic run
identifiers, and resumable execution checkpoints.

## Responsibilities

- Execute plan runs in native harness mode.
- Persist checkpoints under `.octon/engine/_ops/state/agent/checkpoints/`.
- Persist run records under `.octon/engine/_ops/state/agent/runs/`.
- Support `resume=true` with checkpoint restoration.

## Core Guarantees

- No Python runtime dependency is required.
- Missing checkpoints fail closed.
- Resume transitions are explicit and auditable.
- Context-acquisition telemetry fields are always emitted in service output.

## Input and Output Contracts

- Input schema: `schema/input.schema.json`
- Output schema: `schema/output.schema.json`
- Invariants: `contracts/invariants.md`
- Errors: `contracts/errors.yml`

## Required Telemetry Output

Agent output must include:

- `context_acquisition.file_reads`
- `context_acquisition.search_queries`
- `context_acquisition.commands`
- `context_acquisition.subagent_spawns`
- `context_acquisition.duration_ms`
- `context_overhead_ratio`

## Example (execute)

```bash
cat <<'JSON' | .octon/capabilities/runtime/services/execution/agent/impl/agent.sh
{"planPath":"plan.json","resume":false,"memoize":true}
JSON
```

## Example (resume)

```bash
cat <<'JSON' | .octon/capabilities/runtime/services/execution/agent/impl/agent.sh
{"planPath":"plan.json","runId":"run-123","resume":true}
JSON
```
