# Touched Paths Impact Map

Use this when the input is a set of touched repo paths and you need a
deterministic answer to:

- what changed
- what it affects
- what the minimum credible validation set is
- what the next canonical route should be

Expected output sections:

- `impact_map`
- `minimum_credible_validation_set`
- `rationale_trace`
- `recommended_next_step`

This route should fail closed when no path rule yields a credible validation
floor.
