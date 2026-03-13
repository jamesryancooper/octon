# Flow Dependencies

Flow defaults to native Octon runtime execution and only requires core host
capabilities (`fs.read`, `fs.write`, `log.write`).

## Native Path (Default)

- Runtime component: `execution/flow/service.wasm`
- No Python runtime dependency
- Deterministic run record persistence under:
  - `.octon/engine/_ops/state/runs/flow/`

## Optional External Path

When adapter `langgraph-http` is selected, Flow additionally uses `net.http` and
calls a LangGraph-compatible endpoint.

Expected endpoint contract:

- `POST /flows/run`
- Request keys:
  - `runId`
  - `flowName`
  - `canonicalPromptPath`
  - `workflowManifestPath`
  - `workspaceRoot`
  - `params`
  - optional `workflowEntrypoint`
- Response keys (minimum):
  - `result`
  - optional `artifacts`
  - optional `runId` / `runtimeRunId`
