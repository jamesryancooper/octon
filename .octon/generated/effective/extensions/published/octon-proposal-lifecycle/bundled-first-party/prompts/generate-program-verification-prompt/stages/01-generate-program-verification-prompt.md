# Generate Program Verification Prompt

Generate verification that checks parent-level sequence, dependency, risk,
evidence, deferral, and closeout criteria plus child-level acceptance criteria,
validation plans, promotion targets, and implementation evidence. Findings must
state whether they belong to the parent, one child, a child group, or a
cross-packet dependency.

The generated verification prompt must require the eventual verification loop to
write parent-local `support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md`. Each receipt must
include `verdict`, `unresolved_items_count`, `child_receipt_summary_count`, and
`child_authority_preserved`. Use `verdict: pass` and
`child_authority_preserved: yes` only when aggregate program evidence is clean
and child manifests, child receipts, child promotion targets, child validation
verdicts, and child archive metadata remain child-owned.
