# Refactor Target Analysis

You are given `refactor_target` plus optional `validation_depth`,
`strictness`, and `explanation_mode`.

## Required Work

1. Normalize the refactor target into explicit old/new patterns and scope.
2. Reject under-specified rename or move inputs that omit required fields.
3. Derive search variations and the exhaustive reference-check scope.
4. Build `impact_map` from the declared target plus any supplied scope paths.
5. Select `/refactor` as the primary execution route.
6. Add only the extra validators implied by the affected surfaces through
   `context/selection-rules.md`.

## Failure Rule

If the refactor target is not specific enough to audit credibly, return the
shared output contract with `impact_map.status: needs-clarification`.
