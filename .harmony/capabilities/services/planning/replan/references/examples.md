# Replan Reference

```bash
cat <<'JSON' | .harmony/capabilities/services/planning/replan/impl/replan.sh
{"command":"replan","planPath":"plan.json","blockedSteps":["run-tests"]}
JSON
```

```bash
cat <<'JSON' | .harmony/capabilities/services/planning/replan/impl/replan.sh
{"command":"replan","plan":{"goal":"Refresh docs","steps":[{"id":"a"},{"id":"b","depends_on":["a"]}],"order":["a","b"]},"blockedSteps":["a"]}
JSON
```
