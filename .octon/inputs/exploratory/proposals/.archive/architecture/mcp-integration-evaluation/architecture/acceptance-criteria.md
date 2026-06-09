# Acceptance Criteria

- The MCP lab evaluation record exists under `.octon/framework/lab/adapter-evaluations/`.
- The MCP integration-evaluation admission record exists and sets
  `live_effects_authorized`, `connector_availability_is_authority`, and
  `admission_authorizes_execution` to `false`.
- Retained lab evidence records a passing positive scenario and at least three
  passing negative controls.
- `validate-deferred-adapter-evaluation-boundaries.sh` passes.
- Proposal standard, architecture, implementation-readiness, conformance, and
  post-implementation drift validators pass.
- No durable target consumes MCP availability or proposal-local paths as
  runtime, policy, support, or authority truth.
