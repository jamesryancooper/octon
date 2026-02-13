# Flow Dependencies

Primary dependency is a LangGraph-compatible HTTP runtime endpoint.

## Required Runtime

- `FLOW_SERVICE_URL` (optional override)
  - default: `http://127.0.0.1:8410/flows/run`
- `FLOW_SERVICE_TIMEOUT_SECONDS` (optional)
  - default: `30`

## Expected Endpoint Contract

`POST /flows/run` request body:

- `runId`
- `flowName`
- `canonicalPromptPath`
- `workflowManifestPath`
- `workspaceRoot`
- `params` (object)
- optional `workflowEntrypoint`

Expected response (minimum):

- `result` (any JSON)
- optional `artifacts` (array)
- optional `runId` / `runtimeRunId`
