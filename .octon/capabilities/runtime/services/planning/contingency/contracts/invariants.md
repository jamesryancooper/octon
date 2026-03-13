# Contingency Invariants

1. A valid `command` is required (`generate` or `validate`).
2. `plan` input must be an inline object or a readable `planPath`.
3. `failedSteps` must be deterministic arrays of step identifiers.
4. Generated alternatives are topologically ordered and deterministic.
5. `alternatives` output always includes `removedStepIds`, `delta`, and `plan`.
6. Validate mode fail-closes when no alternatives are available.
