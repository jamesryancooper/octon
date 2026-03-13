# Critic Reference Examples

```bash
cat <<'JSON' | .octon/capabilities/runtime/services/planning/critic/impl/critic.sh
{"command":"validate","planPath":"./plan.json","strict":true}
JSON
```

```bash
cat <<'JSON' | .octon/capabilities/runtime/services/planning/critic/impl/critic.sh
{"command":"score","plan":{"goal":"Refresh docs","steps":[{"id":"a"},{"id":"b","depends_on":["a"]}]}}
JSON
```
