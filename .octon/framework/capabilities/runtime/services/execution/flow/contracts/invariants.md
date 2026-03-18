# Flow Invariants

1. `run` requires `config.flowName`, `config.canonicalPromptPath`, and `config.workflowManifestPath`.
2. `dryRun=true` never performs network side effects and returns `result.dryRun=true`.
3. Successful live calls include a stable `runId` and `metadata.runnerEndpoint`.
4. Non-2xx runner responses are surfaced as `UpstreamProviderError` with exit code `6`.
5. Idempotency is required for mutating run operations.
