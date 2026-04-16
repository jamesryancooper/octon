# Mixed Input Analysis

You are given more than one of `touched_paths`, `proposal_packet`, and
`refactor_target`.

## Required Work

1. Normalize every supplied primary input.
2. Compare observed touched paths against proposal or refactor intent.
3. Treat touched paths as the stronger factual source for direct impact claims.
4. Keep proposal or refactor-derived validations only when they still match the
   observed surfaces.
5. Build `impact_map` with explicit drift entries under
   `declared_but_unobserved_surfaces`.
6. Recommend the narrowest corrective next step:
   - packet refresh or supersession for packet drift
   - `/refactor` after scope tightening for refactor drift
   - clarification when the combined inputs are still under-specified

## Failure Rule

If the mixed inputs disagree too much to support a credible validation floor,
return the shared output contract with `impact_map.status: needs-clarification`
or `blocked`.
