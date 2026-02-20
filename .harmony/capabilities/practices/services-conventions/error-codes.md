---
title: Service Error Codes
scope: harness
applies_to: services
---

# Service Error Codes

Service interfaces use a shared numeric exit-code set (`0-8`) and a stable JSON error shape:

```json
{
  "success": false,
  "error": {
    "code": "InputValidationError",
    "exitCode": 5,
    "message": "...",
    "details": {},
    "suggestedAction": "..."
  }
}
```

## Exit Codes

| Exit Code | Name | Meaning | Default HTTP Status |
|---|---|---|---|
| `0` | `SUCCESS` | Operation succeeded. | `200` |
| `1` | `GENERIC_FAILURE` | Unexpected, uncategorized failure. | `500` |
| `2` | `POLICY_VIOLATION` | Request blocked by policy/ruleset. | `403` |
| `3` | `EVALUATION_FAILURE` | Quality/evaluation gate failed threshold. | `422` |
| `4` | `GUARD_VIOLATION` | Safety/content guard blocked execution. | `400` |
| `5` | `INPUT_VALIDATION` | Input contract/schema validation failed. | `400` |
| `6` | `UPSTREAM_PROVIDER` | Dependency/provider/integration failure. | `502` |
| `7` | `IDEMPOTENCY_CONFLICT` | Duplicate/in-flight idempotent request conflict. | `409` |
| `8` | `CACHE_INTEGRITY` | Cache corruption or hash mismatch. | `500` |

## Service Mapping Rules

- Services should preserve semantic equivalence with the table above even when transport differs (CLI, MCP, HTTP, library).
- `error.details` must not include secrets or raw credentials.
- `suggestedAction` is required for operator remediation.
- Unknown runtime exceptions should be wrapped into `GENERIC_FAILURE` (`1`) before returning.
