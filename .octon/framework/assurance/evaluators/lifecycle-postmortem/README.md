# Lifecycle Postmortem Evaluator

The lifecycle-postmortem evaluator is an optional post-run assurance evaluator
for Octon lifecycle processes. It reviews a completed, blocked, cancelled,
rolled-back, or otherwise inspectable lifecycle run after the run has already
executed.

## Inputs

- retained run control refs;
- retained run evidence refs;
- lifecycle purpose and accepted implementation expectations when available;
- known limits produced by the lifecycle-postmortem workflow;
- optional operator-supplied concerns, treated as non-authoritative context.

## Outputs

- Markdown report following
  `.octon/framework/assurance/evaluators/templates/lifecycle-postmortem-template.md`;
- structured output conforming to
  `.octon/framework/constitution/contracts/assurance/lifecycle-postmortem-evaluation-v2.schema.json`;
- optional `review-finding-v1` records when durable traceability is needed.

## Authority Boundary

Evaluator outputs are retained evidence only. They may recommend corrections,
redesign candidates, support blockers, invariant clarifications, or governance
follow-up, but they do not authorize lifecycle transition, closeout, promotion,
support widening, generated-output publication, redesign, or invariant
amendment.

Invariant compliance review asks whether the lifecycle obeyed the invariants.
Invariant validity and evolution review asks whether the invariants themselves
remain correct, complete, enforceable, well-scoped, non-conflicting, and useful.
Both layers are required for Octon lifecycle subjects.

The Markdown report and structured output must preserve the full eighteen-part
postmortem contract: executive summary, intended lifecycle job, reconstruction,
strengths, failures, Chesterton's Fence review, complexity review, constraint
review, patch-versus-redesign gate, redesign triggers, clean-sheet reference
design, alternative paths, quality scoring, Octon invariant review when
applicable, root cause analysis, improvement plan, updated recommendation, and
postmortem closeout.

The v2 contract is the complete implementation of the original rigorous
postmortem prompt. It includes the evaluator role frame, first-principles trap
avoidance, input context blocks, full redesign trigger coverage, major-finding
connection basis, and Octon fit gating. Octon subjects with material invariant
failures, material partial invariant compliance, or blocking unknown invariant
status cannot be marked fit for reuse until those conflicts are corrected.
