# Contingency Examples

- Generate alternatives while preserving deterministic ordering:

```bash
cat <<'JSON' | .octon/capabilities/runtime/services/planning/contingency/impl/contingency.sh
{
  "command":"generate",
  "planPath":"./plan.json",
  "failedSteps":["test"],
  "allowDescendants":true,
  "maxAlternatives":3
}
JSON
```

- Validate mode fail-closes only when no valid alternatives exist:

```bash
cat <<'JSON' | .octon/capabilities/runtime/services/planning/contingency/impl/contingency.sh
{
  "command":"validate",
  "plan":{"goal":"release","steps":[
    {"id":"prepare"},
    {"id":"test","depends_on":["prepare"]},
    {"id":"package","depends_on":["test"]},
    {"id":"deploy","depends_on":["package"]}
  ]},
  "failedSteps":["test"],
  "allowDescendants":true,
  "maxAlternatives":2
}
JSON
```
