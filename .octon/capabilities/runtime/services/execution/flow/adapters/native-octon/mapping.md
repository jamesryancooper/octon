# Native Octon Adapter Mapping

- Adapter id: `native-octon`
- Runtime mode: in-process WASM service execution
- Default: yes

## Input mapping

- `config.flowName` -> native flow run context id
- `config.canonicalPromptPath` -> prompt file validation path
- `config.workflowManifestPath` -> workflow manifest parser source
- `config.workflowEntrypoint` -> optional entrypoint validation
- `params` -> deterministic simulated step context payload

## Output mapping

- Produces deterministic `runId` derived from stable request fields.
- Emits `result.steps[]` from manifest-declared step ids.
- Persists run record to `.octon/engine/_ops/state/runs/flow/<runId>.json`.
