- Validate a plan binding against available capabilities:

```bash
cat <<'JSON' | .harmony/capabilities/services/planning/capability-bind/impl/capability-bind.sh
{
  "command":"validate",
  "plan":{
    "goal":"ship",
    "steps":[
      {"id":"build","requires":["flow","artifacts"]}
    ]
  },
  "requiredCapabilities":["flow","artifacts"],
  "availableCapabilities":{"flow":"native","artifacts":"adapter"}
}
JSON
```

- Discover binding summary only:

```bash
cat <<'JSON' | .harmony/capabilities/services/planning/capability-bind/impl/capability-bind.sh
{
  "command":"bind",
  "planPath":"plan.json",
  "strategy":"prefer-native"
}
JSON
```
