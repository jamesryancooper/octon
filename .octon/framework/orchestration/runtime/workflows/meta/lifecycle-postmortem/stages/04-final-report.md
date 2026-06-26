# Final Report

Validate any supplied Markdown report, structured evaluator output, and optional
review-finding records with `validate-lifecycle-postmortem.sh`.

The validator must require the v2 structured output and the full eighteen
postmortem report sections before treating evaluator output as usable evidence.

Record final postmortem status under the lifecycle-postmortem evidence root.
Validation failures block the postmortem evidence from being treated as usable
post-run assurance evidence, but they do not mutate lifecycle authority.

For v2 binder output, the final report must preserve the distinction between:

- terminal state refs, which can support final lifecycle state and blocker
  conclusions;
- substitute refs, which can reconstruct missing direct program control refs;
- diagnostic refs, which are historical troubleshooting evidence only; and
- associated refs, which support closeout, archive, residue, or publication
  context only when they explicitly name the run id.

The final report remains non-authority evidence. It cannot authorize lifecycle
transition, closeout, promotion, support widening, redesign, generated-output
publication, or invariant amendment.

When a proposal-program delivery postmortem threshold applies, validation must
fail closed unless `evaluation.yml`, `report.md`, `readiness-summary.md`,
`evidence-map.yml`, and digest-bound retained evidence refs are present and
validated by `validate-lifecycle-postmortem.sh`.
