# Flow Errors

| Condition | Surface | Notes |
|---|---|---|
| Missing required config fields | `INVALID_INPUT` trap | Fail-closed input validation.
| Missing prompt or workflow manifest path | `INVALID_INPUT` trap | No execution occurs when required artifacts are missing.
| Adapter contract mismatch | `INVALID_INPUT` trap | Unknown/unsupported adapter configuration.
| External runtime unreachable | `HTTP_ERROR` or `TIMEOUT` trap | Only for `langgraph-http` adapter.
| Missing policy grants (for external adapter) | `CAPABILITY_DENIED` | `net.http` must be granted by runtime policy.
