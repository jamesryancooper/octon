# Flow Errors

| Condition | Exit Code | Notes |
|---|---|---|
| Missing required config fields | `5` | Input validation failure. |
| Missing `jq` / `curl` runtime | `6` | Runtime dependency unavailable. |
| HTTP runner unreachable | `6` | Upstream provider/integration failure. |
| Non-2xx HTTP response | `6` | Upstream flow runner rejected request. |
