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

The generated prompt must also cover parent lifecycle residue handoff
consumption. If `support/lifecycle-residue-cleanup.md` is retained/blocked but
a parent `lifecycle-interaction-return-v1` cites a validating
`closeout-worktree-report-v1` with parent handoff authorization for the current
cleanup receipt, classifier digest or foreign fingerprint, residue fingerprint,
non-mutating disposition, and retained path set, the verification loop may
record `resolved-by-validated-parent-closeout-worktree-return` and proceed when
all other aggregate gates pass. The prompt must state that this disposition
does not authorize deletion, cleanup, archive relocation, Git mutation,
publication edits, `cleaned` claims, promotion, or child-owned evidence.
