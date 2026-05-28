# Program Verification Correction Convergence

Given an implemented parent program with a generated program verification
prompt, `run-program-verification-and-correction-loop` runs while either
parent-local aggregate verification receipt is absent.

The loop writes `support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md` with `verdict`,
`unresolved_items_count`, `child_receipt_summary_count`, and
`child_authority_preserved`.

`generate-program-closeout-prompt`, `closeout-program`, and
`archive-proposal` remain blocked unless both aggregate receipts record
`verdict: pass` and `child_authority_preserved: yes`. These receipts summarize
child state only and never satisfy child receipts, promotion targets,
validation verdicts, archive metadata, or terminal outcomes.
