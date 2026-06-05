# Acceptance Criteria

- The template includes the expanded required postmortem sections.
- The template requires evidence-backed reconstruction rather than stated
  intent alone.
- The template requires the bad-implementation-versus-wrong-architecture
  distinction.
- The template includes Chesterton's Fence, clean-sheet reference design,
  alternative improvement paths, invariant evaluation before scoring, scoring,
  root cause analysis, and closeout actions.
- The template requires an invariant table with invariant, applicability,
  rating, enforcement mechanism, evidence, gap, blocking status, and required
  correction.
- The template lists the required Octon invariant set and restricts ratings to
  Pass, Partial, Fail, Unknown, and Not Applicable.
- The template treats Unknown as insufficient evidence and requires blocking or
  corrective findings for material invariant violations.
- The template includes invariant validity and evolution review after redesign
  pressure and before final recommendations.
- The template evaluates invariant purpose, current validity, scope,
  enforceability, evidenceability, flexibility, precision, duplication,
  conflict, failure coverage, hack pressure, and classification accuracy.
- The template restricts validity/evolution recommendations to Keep, Clarify,
  Strengthen, Relax, Split, Merge, Reclassify, Replace, Remove, and Add.
- The template records the required change and change-control bar for each
  non-Keep invariant recommendation.
- The output schema validates final judgment enum values.
- The output schema validates invariant rating enum values and required
  invariant fields.
- The output schema validates invariant validity/evolution records,
  recommendation categories, and non-authority statements for recommended
  invariant changes.
- The template explains that evaluator results are evidence and cannot approve
  lifecycle closeout, redesign, support widening, or promotion.
- Findings that need durability can map to `review-finding-v1`.
- Review dispositions remain separate from evaluator findings.
