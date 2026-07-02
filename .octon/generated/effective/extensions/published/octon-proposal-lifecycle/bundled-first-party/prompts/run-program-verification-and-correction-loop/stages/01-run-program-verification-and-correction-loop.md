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

When parent lifecycle residue is the only remaining aggregate blocker, inspect
`support/lifecycle-residue-cleanup.md`, any supplied
`lifecycle_interaction_return_refs`, and the default parent return path
`.octon/state/evidence/runs/workflows/<run-id>/lifecycle-interactions/parent-closeout-worktree-return.json`.
Do not repeat the same correction loop merely because the cleanup receipt
itself is retained/blocked. If the return validates with
`validate-lifecycle-interaction-receipts.sh --return <return-ref>`, the returned
`closeout-worktree-report-v1` validates with
`validate-closeout-worktree-wrapper.sh --report <report-ref>`, and the report is
bound to the current parent cleanup receipt, classifier digest or foreign
fingerprint, residue fingerprint, non-mutating disposition, and retained path
set, record the aggregate hygiene disposition as
`resolved-by-validated-parent-closeout-worktree-return`. That disposition may
clear only parent lifecycle closeout/archive-readiness hygiene blocking; it
does not authorize deletion, cleanup, archive relocation, Git mutation,
publication edits, `cleaned` claims, promotion, or child-owned evidence.
