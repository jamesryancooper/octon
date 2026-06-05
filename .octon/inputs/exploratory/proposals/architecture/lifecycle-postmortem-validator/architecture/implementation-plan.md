# Implementation Plan

1. Add `validate-lifecycle-postmortem.sh` with arguments for report path,
   structured output path, and optional run id.
2. Validate the structured output schema first.
3. Validate required Markdown sections when a Markdown report is present.
4. Validate invariant table presence, rating enum values, evidence gaps,
   blocking status, and required corrections for Octon lifecycle subjects.
5. Validate invariant validity/evolution table presence, recommendation enum
   values, required changes, and change-control bars for Octon lifecycle
   subjects.
6. Validate evidence refs and reject generated/input authority claims.
7. Validate final judgment enum and non-authority statement.
8. Validate optional review-finding records.
9. Add positive and negative fixtures under
   `.octon/framework/assurance/runtime/_ops/fixtures/lifecycle-postmortem/`.
10. Add `test-lifecycle-postmortem.sh` to run the fixture matrix.
11. Register the suite and instance assurance surface.

The validator should be deterministic and must not call a model.

Negative fixtures must include missing invariant evaluation, Unknown treated as
Pass, missing invariant evidence gap, and missing blocking correction for
material invariant violations.

Negative fixtures must also include missing invariant validity/evolution
review, invalid invariant recommendation category, missing required change,
weak change-control bar, and a report that claims an invariant change was
approved by the evaluator.
