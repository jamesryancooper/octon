# Prompt Errors

| Condition | Exit Code | Notes |
|---|---|---|
| Unknown prompt id | `5` | Contract/input validation failure. |
| Variable mismatch | `5` | Missing required prompt variables. |
| Runtime/tokenizer dependency failure | `6` | Upstream/provider integration issue. |
