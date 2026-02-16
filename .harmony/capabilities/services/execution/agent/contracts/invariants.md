# Agent Invariants

1. `planPath` is required for all executions.
2. `resume=true` requires an existing `runId` checkpoint context.
3. Output always includes `status`, `runId`, and `result`.
4. Agent failures are fail-closed and surface actionable diagnostics.
