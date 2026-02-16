# LangGraph HTTP Adapter Mapping

- Adapter id: `langgraph-http`
- Runtime mode: external HTTP runtime (`/flows/run`)
- Default: no (opt-in)

## Input mapping

- `config.flowName` -> request `flowName`
- `config.canonicalPromptPath` -> request `canonicalPromptPath`
- `config.workflowManifestPath` -> request `workflowManifestPath`
- `config.workflowEntrypoint` -> request `workflowEntrypoint`
- `config.runtime.url` -> HTTP endpoint base URL (appended with `/flows/run`)
- `params` -> request `params`

## Output mapping

- `response.result` -> service `result`
- `response.artifacts` -> service `artifacts`
- `response.runtimeRunId` or `response.runId` -> metadata `runtimeRunId`
- Writes deterministic local run record in Harmony state directory.
