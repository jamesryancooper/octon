# Lifecycle Postmortem Evaluation Program

This is a non-authoritative Octon architecture proposal program under
`/.octon/inputs/exploratory/proposals/architecture/lifecycle-postmortem-evaluation-program/`.

The program coordinates three sibling child packets:

1. `lifecycle-postmortem-meta-workflow`
2. `lifecycle-postmortem-evaluator-template`
3. `lifecycle-postmortem-validator`

The program implements the recommendation to integrate lifecycle postmortems as
a post-run assurance evaluator. The evaluator consumes retained lifecycle
control and evidence, evaluates Octon invariants as hard constitutional
guardrails, reviews whether those invariants remain valid and well-shaped,
writes retained evaluator evidence, and does not approve, close, promote, or
authorize anything by itself.

## Boundary

The parent may coordinate child sequence, dependency gates, validation posture,
aggregate risk, and closeout expectations.

It must not own child implementation truth, child manifests, child validation
verdicts, child promotion targets, child receipts, or child archive metadata.

## Target Outcome

After child implementation, operators should be able to run a governed
postmortem, for example `octon lifecycle postmortem --run-id <run-id>`, after a
lifecycle process completes. The run should produce retained postmortem
evidence, invariant compliance and validity reviews, and optional durable
review findings while preserving Octon's authority boundaries.
