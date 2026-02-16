# Critic Invariants

1. A valid `command` is required for each invocation.
2. `validate` and `score` both use deterministic dependency analysis.
3. Duplicate step IDs and dependency cycles are deterministic defects.
4. Output always includes `status`, `command`, and `result`.
5. `validate` is fail-closed for critical issues.
