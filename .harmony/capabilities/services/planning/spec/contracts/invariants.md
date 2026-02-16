# Spec Invariants

1. A valid `command` is required for every invocation.
2. `validate` must never mutate target files.
3. Outputs always include `status`, `command`, and `result`.
4. Missing required target paths are fail-closed errors.
