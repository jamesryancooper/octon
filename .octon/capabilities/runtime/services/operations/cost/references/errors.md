# Cost Errors

| Condition | Exit Code | Notes |
|---|---|---|
| Missing required operation fields | `5` | Input contract violation. |
| Unsupported operation | `5` | Only `estimate` and `record` are supported. |
| Missing `jq` dependency | `6` | Runtime dependency issue. |
