# Acceptance Criteria

- The parent program validates with `validate-proposal-program-structure.sh`.
- Each child packet validates with proposal standard and architecture proposal
  validators.
- The meta workflow child defines a read-only post-run workflow with explicit
  evidence inputs, retained outputs, done gates, and no authorization transfer.
- The evaluator-template child defines the lifecycle-postmortem report template
  and structured output contract without changing generic evaluator authority.
- The evaluator-template child places invariant evaluation before quality
  scoring and treats invariants as constitutional guardrails, not optional
  quality attributes.
- The evaluator-template child defines the invariant table fields, rating set,
  required Octon invariant list, and decision consequences for Unknown,
  Partial, and Fail ratings.
- The evaluator-template child includes a separate invariant validity and
  evolution review after redesign pressure and before final recommendations.
- The evaluator-template child defines validity/evolution criteria,
  recommendation categories, and change-control bars for invariant
  clarification, strengthening, relaxation, splitting, merging,
  reclassification, replacement, removal, and addition.
- The validator child defines deterministic report validation, fixtures,
  negative controls, and an instance assurance registration.
- The validator child fails Octon lifecycle reports that omit invariant
  evaluation, treat Unknown as Pass, omit evidence gaps, or fail to mark
  materially blocking invariant violations.
- The validator child fails Octon lifecycle reports that omit invariant
  validity/evolution review, use an invalid invariant recommendation category,
  or present invariant changes as approved rather than proposed evidence.
- Generated and input roots cannot be treated as authority by the proposed
  workflow, evaluator, or validator.
- The postmortem evaluator can report concerns, blockers, and redesign
  recommendations, but those outputs remain evidence until a separate
  disposition or proposal route accepts them.
- The program closeout refuses completion until child-owned implementation,
  conformance, drift/churn, and validation evidence exists for all required
  children.
