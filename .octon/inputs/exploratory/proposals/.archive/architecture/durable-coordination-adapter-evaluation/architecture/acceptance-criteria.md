# Acceptance Criteria

- The durable coordination adapter lab evaluation record exists.
- The durable coordination adapter admission record exists and sets
  `live_effects_authorized`, `connector_availability_is_authority`, and
  `admission_authorizes_execution` to `false`.
- Retained lab evidence records a passing positive scenario and at least three
  passing negative controls.
- `validate-deferred-adapter-evaluation-boundaries.sh` passes.
- Proposal standard, architecture, implementation-readiness, conformance, and
  post-implementation drift validators pass.
- No durable target consumes external durable adapter state as canonical
  control, evidence, authority, support, or closeout truth.
