# Run Program Verification And Correction Loop

Run parent-level and child-level verification, generate targeted program
correction prompts, apply corrections within the declared parent or child
scope, and repeat until a declared terminal state is reached. Retain every
pass and stop if a child requires revision, rejection, supersession, or
explicit deferral.

On terminal aggregate pass, write parent-local
`support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md` with `verdict`,
`unresolved_items_count`, `child_receipt_summary_count`, and
`child_authority_preserved`. These receipts may summarize child state but do
not satisfy child receipts, child promotion targets, child validation verdicts,
child archive metadata, or child terminal outcomes.
