# Rollback Plan

Registry rollback posture for this child is `manual`. Every surface this child
touches is an existing file being extended (no new live authority is created
except the child evidence root and new validator fixtures), so rollback is a
`git revert` of the promotion commits plus a projection re-refresh.

## Rollback Units

Each promotion target family lands as a single revertible promotion commit and
reverts independently:

1. **Workflow method-recording family** — revert restores the prior
   `workflow.yml` / stage bytes for all four review occasions. Effect: review
   runs stop recording the method id; the support receipt was never changed, so
   the gating path is unaffected.
2. **Navigation family** — revert restores the prior feature note, mechanism
   entry, and `index.yml` bytes. Effect: the method-layer descriptions and
   advisory disappear; no behavior changes (navigation-only).
3. **Validator family** — revert restores the prior
   `validate-architectural-review-workflows.sh` and removes the new fixtures.
   Effect: the method-recording assertion is withdrawn; all prior checks
   return unchanged.
4. **Projection refresh** — re-run the canonical publishers after the reverts
   so the generated projections match the reverted framework state. Generated
   files are derived-only; no manual generated edits to undo.

## Rollback Procedure

1. Identify the promotion commit(s) for the affected families.
2. `git revert` the commit(s); new-content additions (fixtures, evidence root)
   revert to absence, extended files revert to their prior committed bytes.
3. Re-run the affected canonical publishers so projections are fresh against
   the reverted state.
4. Re-run the packet validators (`validate-proposal-standard.sh`,
   `validate-architecture-proposal.sh`) and the full architectural-review
   validator suite to prove the repository returned to a coherent
   pre-promotion state.

## Interaction With Dependencies

Rolling back this integration child does **not** roll back the landed method
docs, lens bank, naming/routing v2, or v2 schemas — those are separately-owned
children and remain in place. After a rollback, routing v2's `method_selection`
simply has no run-evidence expression again (the pre-integration gap), which is
a coherent prior state.

## Safety Invariants

- No rollback step writes under `.octon/generated/**` by hand.
- No rollback step edits another child's write scope.
- If a revert cannot restore one coherent state (e.g. partial family revert),
  stop with a precise manual recovery note and make no further writes.
