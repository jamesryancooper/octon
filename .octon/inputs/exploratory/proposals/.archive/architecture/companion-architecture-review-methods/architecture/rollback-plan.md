# Rollback Plan

Rollback posture: **manual** (per the child registry). The change is additive,
file-scoped documentation with no runtime state, so rollback is clean deletion and
reversion with no data or migration concerns.

## What Rollback Reverts

1. Delete the four new docs:
   - `architectural-review/tradeoff-review-method.md`
   - `architectural-review/failure-mode-review-method.md`
   - `architectural-review/evolution-fitness-review-method.md`
   - `architectural-review/boundary-authority-review-method.md`
2. Remove the four additive `doc:` pointers from the companion
   `methods.catalog` entries in `naming.yml`.
3. Remove the four References links from `README.md`.

After reversion, `naming.yml`, `review-routing.yml`, and `lens-bank.yml` return to
their pre-change state: the four companion methods remain declared and
lens-profiled (as they are today) but undocumented — i.e. the exact current state.

## Safety Properties

- **No consumer breakage.** Method selection semantics live in `naming.yml`
  `methods.catalog` and `review-routing.yml` `method_selection`, which this child
  does not change. Removing the docs and their pointers does not un-declare any
  method or alter routing/fail-closed behavior.
- **No dangling references.** Because the only inbound references to the new docs
  are the additive `naming.yml` `doc:` pointers and `README.md` links removed in
  the same rollback, deletion leaves no dangling link. (Confirm no other file
  began linking the docs before rollback; if
  `architectural-review-suite-integration` has already shipped and references the
  method ids, coordinate — those references are to method *slugs*, which persist,
  not to the doc files.)
- **No generated drift.** This child writes no generated projection, so there is
  no derived artifact to rebuild on rollback beyond the coordinated proposal
  registry refresh.

## Rollback Verification

- [ ] The three regression validators still report `errors=0` post-rollback
      (they do not depend on the docs).
- [ ] `git status` shows only the reverted paths.
- [ ] Retain a short rollback note under
      `.octon/state/evidence/validation/proposals/companion-architecture-review-methods/`
      recording the reason and the reverted paths.

## Trigger Conditions

- A post-promotion finding that a doc materially misstates a method's contract,
  boundary, or lens profile and cannot be corrected forward safely.
- Discovery that the additive `naming.yml`/`README.md` edits collided with another
  child's owned change in the same directory.
