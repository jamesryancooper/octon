# Classification Mapping Receipt

proposal_id: workflow-capability-human-boundary-classification
run_id: 2026-06-09T21-35-00Z
verdict: pass

## Durable Mapping

- `execution-role-ready` maps to delegated execution, requires explicit
  delegation proof, and is the only class with autonomous execution allowed.
- `role-mediated` maps to grant consumption, requires an already-bound grant,
  and does not create new approval authority from route, workflow, extension,
  importance, or generated-index shape.
- `human-only` maps to typed human exception handling, requires a typed human
  boundary, and sets autonomous execution to false.

## Human Boundary

The `audit-pre-release` workflow now carries the
`pre-release-risk-acceptance` typed human boundary. The boundary records a
release risk acceptance decision that is not machine-provable.
