# Acceptance Criteria

- The external workflow engine adapter lab evaluation record exists.
- The external workflow engine adapter admission record exists and sets
  `live_effects_authorized`, `connector_availability_is_authority`, and
  `admission_authorizes_execution` to `false`.
- Retained lab evidence records a passing positive scenario and at least three
  passing negative controls.
- `validate-deferred-adapter-evaluation-boundaries.sh` passes.
- Proposal standard, architecture, implementation-readiness, conformance, and
  post-implementation drift validators pass.
- No durable target consumes external workflow engine state as canonical
  workflow, run, authorization, support, evidence, or closeout truth.
