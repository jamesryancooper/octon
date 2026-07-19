# Closeout Change Decisions

1. Direct-main request -> deny with
   `RP00_CONTAINMENT_PUBLICATION_DISABLED`.
2. Independent PR predicate -> `branch-pr`, stage-preserving only.
3. Branch isolation without a PR predicate -> `branch-no-pr`, preservation
   only.
4. Missing authority, ownership, validation, or rollback ->
   `stage-only-escalate`.
5. Landing/publication request -> preserve and record
   `RP00_CONTAINMENT_PUBLICATION_DISABLED`.
6. Cleanup/ref/worktree mutation request -> preserve and record
   `RP00_CONTAINMENT_CLEANUP_DISABLED`.

A generic closeout target is `preserved`. An independently established landing
may be observed as `landed` plus cleanup deferred, but never effected here.
