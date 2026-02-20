# Guard Errors

| Condition | Exit Code | Notes |
|---|---|---|
| Missing/invalid JSON input | `5` | Input validation failure. |
| Missing `content` field | `5` | Input schema violation. |
| Missing `jq` dependency | `6` | Runtime/integration dependency failure. |

Guardrail findings are returned in normal output (`passed: false`), not as process-level errors.
