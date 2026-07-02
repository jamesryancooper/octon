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
`archive_authorized`, `child_authority_preserved`, `selected_git_route`,
`worktree_hygiene_verdict`, `worktree_hygiene_blocker_class`,
`worktree_hygiene_owned_path_count`, `worktree_hygiene_in_scope_path_count`,
`worktree_hygiene_foreign_path_count`,
`worktree_hygiene_foreign_fingerprint`, `worktree_hygiene_evidence`,
`cleanup_summary`, and `next_route_condition`.

Use `verdict: pass`, `archive_authorized: yes`, and
`child_authority_preserved: yes` only when the active `program.closeout_policy`
passes, the parent closeout is complete, and child manifests, child receipts,
child promotion targets, child validation verdicts, child archive metadata, and
child terminal outcomes remain child-owned. If closeout or archive readiness is
blocked, write `verdict: blocked`, `archive_authorized: no`,
`selected_git_route: stage-only-escalate`, the blocker class and hygiene counts
reported by the read-only classifier, a cleanup summary, and a nonterminal
`next_route_condition` such as `closeout-change or operator scope resolution`.

If the only closeout/archive-readiness blocker is parent worktree hygiene
already dispositioned by `closeout-worktree`, accept it only after validating
the parent `lifecycle-interaction-return-v1` and cited
`closeout-worktree-report-v1`. The report must contain parent handoff
authorization to `preserve-and-exclude-from-lifecycle-closeout-blocking` bound
to the current classifier digest or foreign fingerprint, cleanup receipt,
residue fingerprint, non-mutating disposition, and retained path set. In that
case the closeout receipt may record
`worktree_hygiene_verdict: resolved-by-validated-parent-closeout-worktree-return`
and proceed if all other closeout gates pass. The accepted handoff is not
cleanup authority, archive authorization, Git mutation authority, publication
authority, a `cleaned` claim, promotion authority, or child-owned evidence.
