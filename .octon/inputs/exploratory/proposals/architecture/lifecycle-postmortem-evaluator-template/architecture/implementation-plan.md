# Implementation Plan

1. Add `.octon/framework/assurance/evaluators/lifecycle-postmortem/README.md`
   describing evaluator purpose, inputs, outputs, and authority boundary.
2. Add `.octon/framework/assurance/evaluators/templates/lifecycle-postmortem-template.md`
   with the expanded required postmortem structure, placing invariant
   evaluation before quality scoring and invariant validity/evolution review
   before final recommendations.
3. Add `.octon/framework/constitution/contracts/assurance/lifecycle-postmortem-evaluation-v1.schema.json`
   for structured evaluator outputs, including invariant compliance records,
   invariant validity/evolution records, invariant rating enum, and invariant
   recommendation enum.
4. Update evaluator routing only enough to identify lifecycle-postmortem as an
   optional post-run evaluator.
5. Add examples or fixture expectations only if the validator child consumes
   them.
6. Validate with the schema validator and lifecycle-postmortem validator.

Do not change the existing generic evaluator-review schema unless the new
template cannot be expressed as a subtype evidence artifact.

The implementation must not soften invariant findings into ordinary quality
scores. Unknown, Fail, and material Partial ratings remain evidence gaps or
blocking/corrective findings until separately resolved.

The implementation must not turn invariant validity/evolution recommendations
into approved invariant changes. Those recommendations are evidence-only and
must route through separate governance, proposal, or constitutional amendment
work before they alter authority.
