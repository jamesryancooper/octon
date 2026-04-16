# Refactor Target Impact Map

Use this when the input is a rename, move, or restructure target rather than
already-observed touched paths.

Route behavior:

- normalizes the refactor intent into explicit old/new patterns
- derives the exhaustive reference-check scope
- selects `/refactor` as the primary execution route
- adds only the extra validators implied by the affected surfaces

Expected output sections:

- `impact_map`
- `minimum_credible_validation_set`
- `rationale_trace`
- `recommended_next_step`
