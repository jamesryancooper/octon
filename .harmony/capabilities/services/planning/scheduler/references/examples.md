# Scheduler Examples

```bash
cat <<'JSON' | .harmony/capabilities/services/planning/scheduler/impl/scheduler.sh
{"command":"schedule","maxParallel":2,"plan":{"goal":"release","steps":[{"id":"a","depends_on":[]},{"id":"b","depends_on":["a"},{"id":"c","depends_on":["a"]},{"id":"d","depends_on":["b","c"]}]}}
JSON
```
