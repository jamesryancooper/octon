# Closeout Program

Verify every child is implemented, archived, rejected, superseded, or covered by
an explicitly deferred report outcome with rationale; follow child closeout
order; retain aggregate evidence; verify durable targets have no parent or
child proposal path dependency; regenerate registry only when safe; archive the
parent only after child lifecycle outcomes are coherent.

Require passing parent-local aggregate verification receipts before writing
closeout evidence: `support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md` must both record
`verdict: pass` and `child_authority_preserved: yes`.

For PR, CI, review, merge, branch cleanup, and sync behavior, defer to the
shared Git/worktree autonomy contract when a child route uses a PR or branch
lane, and do not create program-specific GitHub policy. Program closeout is
incomplete while any required child lifecycle state, aggregate evidence, final
hygiene, route-required review, route-required check, merge, cleanup, or sync
gate remains unresolved unless the outcome is explicitly reported as blocked or
deferred.

Write parent-local `support/proposal-closeout.md` with `verdict`, `closed_at`,
`archive_authorized`, and `child_authority_preserved`. Use `verdict: pass`,
`archive_authorized: yes`, and `child_authority_preserved: yes` only when the
parent closeout is complete and child manifests, child receipts, child
promotion targets, child validation verdicts, child archive metadata, and child
terminal outcomes remain child-owned.
