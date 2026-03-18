# Replan Invariants

1. A valid `command` is required for every invocation.
2. Input must include exactly one valid plan source (`plan` or `planPath`).
3. Blocked steps and dependent steps are removed deterministically.
4. Replanned output is deterministic for stable input.
5. Output includes `result.replannedPlan` and `result.delta`.
