# Scheduler Invariants

1. `command` must be `schedule`.
2. Every input step must have a non-empty `id`.
3. Dependencies are validated before scheduling; missing dependencies fail closed unless overridden by source plan repair.
4. Output must include deterministic `status`, `command`, and `result`.
5. Scheduling output is deterministic for the same input payload.
