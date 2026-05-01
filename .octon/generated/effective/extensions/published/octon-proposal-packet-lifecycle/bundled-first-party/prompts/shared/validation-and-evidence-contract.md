# Validation And Evidence Contract

Lifecycle routes must name the validation commands or deterministic checks
that prove their output. Verification findings must include stable ids,
severity, affected paths, evidence, expected behavior, correction scope,
acceptance criteria, and deferral eligibility.

Evidence should be retained in existing Octon evidence roots:

- `.octon/state/evidence/validation/**`
- `.octon/state/evidence/runs/skills/**`
- `.octon/state/evidence/runs/workflows/**`
- `.octon/state/control/skills/checkpoints/**` for resumable loops

Evidence must not be stored in `generated/**`, and generated prompt files must
not substitute for implementation evidence.
